require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { METHOD_METADATA, PATH_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

const context = {
  authorization: 'Bearer test',
  actorId: 'owner-user',
  userId: 'owner-user',
  organizationId: 'org-owner',
  actorRole: 'buyer_admin',
  requestId: 'request-forum-inbox',
  traceId: 'trace-forum-inbox',
};

function makePost(overrides = {}) {
  return {
    id: 'post-owner-1',
    postNo: 'FP-1',
    organizationId: 'org-owner',
    authorUserId: 'owner-user',
    authorActorId: 'owner-user',
    authorOrganizationId: 'org-owner',
    sourceDraftId: null,
    topicId: 'topic-1',
    title: '我的帖子',
    body: 'body',
    excerpt: 'excerpt',
    attachmentFileAssetIds: [],
    state: 'published',
    commentCount: 0,
    lastModerationCaseId: null,
    publishedAt: new Date('2026-04-24T10:00:00.000Z'),
    hiddenAt: null,
    archivedAt: null,
    createdAt: new Date('2026-04-24T10:00:00.000Z'),
    updatedAt: new Date('2026-04-24T10:00:00.000Z'),
    ...overrides,
  };
}

function makeComment(overrides = {}) {
  return {
    id: 'comment-1',
    postId: 'post-owner-1',
    parentCommentId: null,
    organizationId: 'org-other',
    authorUserId: 'other-user',
    authorActorId: 'other-user',
    body: '评论内容',
    state: 'published',
    publishedAt: new Date('2026-04-24T11:00:00.000Z'),
    createdAt: new Date('2026-04-24T11:00:00.000Z'),
    updatedAt: new Date('2026-04-24T11:00:00.000Z'),
    ...overrides,
  };
}

function makeLike(overrides = {}) {
  return {
    id: 'like-1',
    postId: 'post-owner-1',
    userId: 'other-user',
    actorId: 'other-user',
    organizationId: 'org-other',
    createdAt: new Date('2026-04-24T12:00:00.000Z'),
    updatedAt: new Date('2026-04-24T12:00:00.000Z'),
    ...overrides,
  };
}

function makeFollow(overrides = {}) {
  return {
    id: 'follow-1',
    followerUserId: 'other-user',
    followerActorId: 'other-user',
    followerOrganizationId: 'org-other',
    targetAuthorUserId: 'owner-user',
    targetOrganizationId: 'org-owner',
    createdAt: new Date('2026-04-24T13:00:00.000Z'),
    updatedAt: new Date('2026-04-24T13:00:00.000Z'),
    ...overrides,
  };
}

function makeService(options = {}) {
  const posts = options.posts ?? [makePost()];
  const comments = options.comments ?? [];
  const likes = options.likes ?? [];
  const follows = options.follows ?? [];
  const calls = [];

  const postRepository = {
    find: async (query) => {
      calls.push(['post.find', query]);
      const where = query.where ?? {};
      if (where.authorUserId) {
        return posts.filter(
          (post) =>
            post.authorUserId === where.authorUserId &&
            post.organizationId === where.organizationId &&
            post.state === where.state
        );
      }
      if (where.state) {
        return posts.filter((post) => post.state === where.state);
      }
      return posts;
    },
    findOne: async (query) => {
      calls.push(['post.findOne', query]);
      const where = query.where ?? {};
      return (
        posts.find(
          (post) =>
            post.authorUserId === where.authorUserId &&
            post.organizationId === where.organizationId &&
            post.state === where.state
        ) ?? null
      );
    },
  };
  const commentRepository = {
    find: async (query) => {
      calls.push(['comment.find', query]);
      const where = query.where ?? {};
      if (Array.isArray(where)) {
        return comments.filter((comment) => comment.state === 'published');
      }
      if (where.authorUserId) {
        return comments.filter(
          (comment) =>
            comment.authorUserId === where.authorUserId &&
            comment.organizationId === where.organizationId &&
            comment.state === where.state
        );
      }
      return comments;
    },
  };
  const likeRepository = {
    find: async (query) => {
      calls.push(['like.find', query]);
      return likes;
    },
  };
  const authorFollowRepository = {
    find: async (query) => {
      calls.push(['follow.find', query]);
      return follows;
    },
  };
  const authorDirectory = {
    'owner-user': {
      authorId: 'owner-user',
      displayName: '我',
      avatarUrl: null,
      organizationName: '我的公司',
    },
    'other-user': {
      authorId: 'other-user',
      displayName: '互动用户',
      avatarUrl: null,
      organizationName: '对方公司',
    },
  };
  const authorProjectionService = {
    buildAuthorSnapshotMap: async (records) =>
      new Map(
        records
          .map((record) => {
            const author = authorDirectory[record.authorUserId];
            return author ? [record.id, author] : null;
          })
          .filter(Boolean)
      ),
  };
  const verifier = options.verifier ?? {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: context.actorId,
        userId: context.userId,
        organizationId: context.organizationId,
        requestId: context.requestId,
        traceId: context.traceId,
      },
    }),
  };
  const eligibility = {
    requireAuthenticatedActor: async () => ({ id: context.userId, status: 'active' }),
    getCurrentOrganizationScope: async () => ({ organization: { id: 'org-owner' } }),
  };

  const {
    ForumInteractionInboxQueryService,
  } = require('../dist/modules/forum/forum-interaction-inbox.query.service.js');
  const {
    ForumInteractionInboxPresenter,
  } = require('../dist/modules/forum/forum-interaction-inbox.presenter.js');
  return {
    calls,
    service: new ForumInteractionInboxQueryService(
      commentRepository,
      postRepository,
      likeRepository,
      authorFollowRepository,
      authorProjectionService,
      verifier,
      eligibility,
      new ForumInteractionInboxPresenter()
    ),
  };
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

test('forum interaction inbox server route is materialized', () => {
  const { ForumController } = require('../dist/modules/forum/forum.controller.js');

  assert.equal(
    Reflect.getMetadata(PATH_METADATA, ForumController.prototype.getInteractionInbox),
    'interaction/inbox'
  );
  assert.equal(
    Reflect.getMetadata(METHOD_METADATA, ForumController.prototype.getInteractionInbox),
    RequestMethod.GET
  );
});

test('forum interaction inbox replies projects comments and comment replies', async () => {
  const ownComment = makeComment({
    id: 'comment-own',
    postId: 'post-other-1',
    organizationId: 'org-owner',
    authorUserId: 'owner-user',
    body: '我自己的评论',
    publishedAt: new Date('2026-04-24T10:30:00.000Z'),
  });
  const { service } = makeService({
    posts: [
      makePost(),
      makePost({
        id: 'post-other-1',
        organizationId: 'org-other',
        authorUserId: 'other-user',
        title: '别人的帖子',
      }),
    ],
    comments: [
      ownComment,
      makeComment({
        id: 'comment-on-post',
        body: '评论了你的帖子',
        publishedAt: new Date('2026-04-24T11:00:00.000Z'),
      }),
      makeComment({
        id: 'comment-on-comment',
        postId: 'post-other-1',
        parentCommentId: 'comment-own',
        body: '回复了你的评论',
        publishedAt: new Date('2026-04-24T11:10:00.000Z'),
      }),
    ],
  });

  const result = await service.getInteractionInbox('replies', undefined, '10', context);

  assert.equal(result.items.length, 2);
  assert.deepEqual(
    result.items.map((item) => item.notificationId),
    ['forum-reply:comment-on-comment', 'forum-reply:comment-on-post']
  );
  assert.equal(result.items[0].tab, 'replies');
  assert.equal(result.items[0].targetType, 'forum_comment');
  assert.equal(result.items[1].targetType, 'forum_post');
  assert.equal(result.page.hasMore, false);
});

test('forum interaction inbox likes projects other users likes on owned posts', async () => {
  const { service } = makeService({
    likes: [
      makeLike({ id: 'like-other', userId: 'other-user' }),
      makeLike({ id: 'like-self', userId: 'owner-user' }),
    ],
  });

  const result = await service.getInteractionInbox('likes', undefined, '10', context);

  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].notificationId, 'forum-like:like-other');
  assert.equal(result.items[0].tab, 'likes');
  assert.equal(result.items[0].targetType, 'forum_post');
  assert.equal(result.items[0].targetId, 'post-owner-1');
});

test('forum interaction inbox follows projects other users follows through safe source object', async () => {
  const { service } = makeService({
    follows: [
      makeFollow({ id: 'follow-other', followerUserId: 'other-user' }),
      makeFollow({ id: 'follow-self', followerUserId: 'owner-user' }),
    ],
  });

  const result = await service.getInteractionInbox('follows', undefined, '10', context);

  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].notificationId, 'forum-follow:follow-other');
  assert.equal(result.items[0].tab, 'follows');
  assert.equal(result.items[0].targetType, 'forum_post');
  assert.equal(result.items[0].targetId, 'post-owner-1');
});

test('forum interaction inbox returns controlled empty collection', async () => {
  const { service } = makeService({ posts: [], comments: [], likes: [], follows: [] });

  const result = await service.getInteractionInbox('replies', undefined, undefined, context);

  assert.deepEqual(result, { items: [], page: { nextCursor: null, hasMore: false } });
});

test('forum interaction inbox requires current session', async () => {
  const { service } = makeService({
    verifier: {
      verifyCurrentSessionContext: async () => ({
        outcome: 'failed',
        reason: 'missing_current_session_carrier',
        requestId: context.requestId,
        traceId: context.traceId,
      }),
    },
  });

  await assert.rejects(
    () => service.getInteractionInbox('replies', undefined, undefined, context),
    hasErrorCode('AUTH_SESSION_INVALID')
  );
});

test('forum interaction inbox rejects illegal tab before projection', async () => {
  const { service } = makeService();

  await assert.rejects(
    () => service.getInteractionInbox('unknown', undefined, undefined, context),
    hasErrorCode('FORUM_INTERACTION_INBOX_INVALID')
  );
});
