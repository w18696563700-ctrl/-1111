require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');

function createVerifier() {
  return {
    async verifyCurrentSessionContext() {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'actor-user',
          userId: 'actor-user',
          organizationId: 'actor-org',
          requestId: 'request-1',
          traceId: 'trace-1',
        },
      };
    },
  };
}

function createScope() {
  return {
    organization: {
      id: 'actor-org',
      displayName: 'Actor Org',
    },
  };
}

function createManager({ existingLike = null, existingFollow = null } = {}) {
  const saved = {
    comments: [],
    likes: [],
    follows: [],
    increments: [],
  };
  const manager = {
    saved,
    getRepository(entity) {
      const name = String(entity?.name ?? '');
      if (name.includes('ForumCommentEntity')) {
        return {
          async save(value) {
            saved.comments.push(value);
            return value;
          },
        };
      }
      if (name.includes('ForumPostEntity')) {
        return {
          async increment(criteria, field, count) {
            saved.increments.push({ criteria, field, count });
          },
        };
      }
      if (name.includes('ForumPostLikeEntity')) {
        return {
          async findOneBy() {
            return existingLike;
          },
          create(value) {
            return value;
          },
          async save(value) {
            saved.likes.push(value);
            return value;
          },
          async delete() {},
        };
      }
      if (name.includes('ForumAuthorFollowEntity')) {
        return {
          async findOneBy() {
            return existingFollow;
          },
          create(value) {
            return value;
          },
          async save(value) {
            saved.follows.push(value);
            return value;
          },
          async delete() {},
        };
      }
      throw new Error(`Unexpected repository ${name}`);
    },
  };
  return manager;
}

function createService({
  post = {
    id: 'post-1',
    state: 'published',
    authorUserId: 'owner-user',
    organizationId: 'owner-org',
  },
  parentComment = null,
  latestPost = null,
  existingLike = null,
  existingFollow = null,
} = {}) {
  const notifications = [];
  let manager;
  const postRepository = {
    async findOneBy() {
      return post;
    },
    async findOne() {
      return latestPost ?? post;
    },
  };
  const commentRepository = {
    async findOneBy() {
      return parentComment;
    },
    create(value) {
      return value;
    },
  };
  const likeRepository = {
    async countBy() {
      return 1;
    },
  };
  const dataSource = {
    async transaction(callback) {
      manager = createManager({ existingLike, existingFollow });
      return callback(manager);
    },
  };
  const eligibilityService = {
    async requireAuthenticatedActor() {},
    async getCurrentOrganizationScope() {
      return createScope();
    },
  };
  const presenter = {
    toCommentAcceptedResponse(value) {
      return { accepted: true, commentId: value.id };
    },
    toPostLikeToggleResponse(value) {
      return value;
    },
    toAuthorFollowToggleResponse(value) {
      return value;
    },
  };
  const notificationService = {
    async createForumInteractionNotification(command) {
      notifications.push(command);
      return { id: `notification-${notifications.length}` };
    },
  };
  const {
    ForumCommentService,
  } = require('../dist/modules/forum/forum-comment.service.js');
  const service = new ForumCommentService(
    postRepository,
    commentRepository,
    likeRepository,
    {},
    {},
    dataSource,
    createVerifier(),
    eligibilityService,
    {},
    presenter,
    notificationService,
  );
  return { service, notifications, getManager: () => manager };
}

test('forum comment creates a forum interaction notification for the post owner', async () => {
  const { service, notifications, getManager } = createService();

  await service.createComment(
    {
      postId: 'post-1',
      body: '评论内容',
    },
    { requestId: 'request-1', traceId: 'trace-1', headers: {} },
  );

  assert.equal(notifications.length, 1);
  assert.deepEqual(notifications[0], {
    tab: 'replies',
    title: '有新的论坛回复',
    body: '有人评论了你的帖子。',
    recipientUserId: 'owner-user',
    recipientOrganizationId: 'owner-org',
    actorUserId: 'actor-user',
    targetId: 'post-1',
  });
  assert.equal(getManager().saved.comments.length, 1);
  assert.equal(getManager().saved.increments.length, 1);
});
test('forum like creates a forum interaction notification for the post owner', async () => {
  const { service, notifications, getManager } = createService();

  const response = await service.deferLike(
    {
      postId: 'post-1',
      action: 'like',
    },
    { requestId: 'request-1', traceId: 'trace-1', headers: {} },
  );

  assert.equal(response.viewerHasLiked, true);
  assert.equal(notifications.length, 1);
  assert.equal(notifications[0].tab, 'likes');
  assert.equal(notifications[0].recipientUserId, 'owner-user');
  assert.equal(notifications[0].recipientOrganizationId, 'owner-org');
  assert.equal(notifications[0].targetId, 'post-1');
  assert.equal(getManager().saved.likes.length, 1);
});

test('forum follow creates a forum interaction notification for the target author', async () => {
  const { service, notifications, getManager } = createService({
    latestPost: {
      id: 'post-2',
      state: 'published',
      authorUserId: 'target-user',
      organizationId: 'target-org',
    },
  });

  const response = await service.toggleAuthorFollow(
    {
      authorId: 'target-user',
      action: 'follow',
    },
    { requestId: 'request-1', traceId: 'trace-1', headers: {} },
  );

  assert.equal(response.viewerFollowsAuthor, true);
  assert.equal(notifications.length, 1);
  assert.equal(notifications[0].tab, 'follows');
  assert.equal(notifications[0].recipientUserId, 'target-user');
  assert.equal(notifications[0].recipientOrganizationId, 'target-org');
  assert.equal(notifications[0].targetId, 'target-user');
  assert.equal(getManager().saved.follows.length, 1);
});
