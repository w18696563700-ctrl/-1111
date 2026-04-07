import { Injectable } from '@nestjs/common';

type HomeLocationSource = 'manual_selection' | 'device_location' | 'system_default';
type HomeSelectionScope = 'request_only';

export type ExhibitionHomeLocationInput = {
  displayName: string;
  provinceCode: string | null;
  provinceName: string;
  cityName: string | null;
  districtName: string | null;
  latitude: number | null;
  longitude: number | null;
  source: HomeLocationSource;
  selectionScope: HomeSelectionScope;
  selectionNotice: string;
  isUsingDeviceLocation: boolean;
};

@Injectable()
export class ExhibitionHomePresenter {
  toReadModel(location: ExhibitionHomeLocationInput) {
    const updatedAt = new Date().toISOString();

    return {
      currentLocation: {
        displayName: location.displayName,
        provinceCode: location.provinceCode,
        provinceName: location.provinceName,
        cityName: location.cityName,
        districtName: location.districtName,
        latitude: location.latitude,
        longitude: location.longitude,
        source: location.source,
        persisted: false
      },
      selectionScope: location.selectionScope,
      isUsingDeviceLocation: location.isUsingDeviceLocation,
      currentWeather: '待同步',
      currentTemperature: 0,
      highTemperature: 0,
      lowTemperature: 0,
      precipitationProbability: 0,
      constructionRiskLevel: 'medium',
      constructionRiskSummary:
        '今日施工重点：当前已同步地区真值；天气部分暂按受控占位返回，请以现场实时情况为准。',
      riskTags: [],
      riskTimeLabel: null,
      nightRainExpected: false,
      nightRainTimeLabel: null,
      officialAlerts: [],
      constructionSuggestions: [
        '当前天气建议仍是受控占位，请在施工前复核现场实时天气。',
        '可继续使用重新定位或手动选择地区，更新首页当前地区说明。',
        '登录后的私域项目继续动作仍以项目列表和工作台真值为准。'
      ],
      hourlyForecast: [],
      dailyForecast: [],
      updatedAt,
      sourceLabel: this.toSourceLabel(location.source),
      selectionNotice: location.selectionNotice,
      canExpand: true,
      refreshable: true,
      modules: this.toModules(),
      recommendationSections: this.toRecommendationSections(location.provinceName)
    };
  }

  private toSourceLabel(source: HomeLocationSource) {
    switch (source) {
      case 'manual_selection':
        return '当前首页按手动选择地区返回最小真值';
      case 'device_location':
        return '当前首页按定位提示返回最小真值';
      case 'system_default':
        return '当前首页按系统默认地区返回最小真值';
    }
  }

  private toModules() {
    return [
      {
        moduleKey: 'project_showcase',
        title: '项目展示',
        summary: '公开项目展示继续由项目真值承接，首页只保留导流摘要。',
        statusLabel: '已接通',
        actionLabel: '进入模块',
        enabled: true,
        placeholder: false
      },
      {
        moduleKey: 'excellent_company',
        title: '优秀公司',
        summary: '优秀公司入口已接通，首页当前只保留轻摘要，不伪装成完整推荐流。',
        statusLabel: '已接通',
        actionLabel: '进入列表',
        enabled: true,
        placeholder: false
      },
      {
        moduleKey: 'excellent_factory',
        title: '优秀工厂',
        summary: '优秀工厂入口已接通，首页当前只保留轻摘要，不伪装成完整推荐流。',
        statusLabel: '已接通',
        actionLabel: '进入列表',
        enabled: true,
        placeholder: false
      },
      {
        moduleKey: 'excellent_supplier',
        title: '优秀供应商',
        summary: '优秀供应商入口已接通，首页当前只保留轻摘要，不伪装成完整推荐流。',
        statusLabel: '已接通',
        actionLabel: '进入列表',
        enabled: true,
        placeholder: false
      },
      {
        moduleKey: 'forum',
        title: '展览论坛',
        summary: '论坛继续保持独立入口，首页这里只提供受控导流。',
        statusLabel: '已接通',
        actionLabel: '打开论坛',
        enabled: true,
        placeholder: false
      },
      {
        moduleKey: 'excellent_team_member',
        title: '优秀团队员工',
        summary: '团队与员工推荐当前仍是受控占位，首页不会伪装成已接通推荐内容。',
        statusLabel: '占位',
        actionLabel: '查看说明',
        enabled: true,
        placeholder: true
      }
    ];
  }

  private toRecommendationSections(provinceName: string) {
    return [
      {
        sectionKey: 'project_recommendations',
        title: `${provinceName}项目推荐`,
        items: [],
        canLoadMore: true,
        nextCursor: null
      },
      {
        sectionKey: 'forum_hot_posts',
        title: '论坛热帖',
        items: [],
        canLoadMore: true,
        nextCursor: null
      },
      {
        sectionKey: 'company_factory_recommendations',
        title: '优秀公司与工厂',
        items: [],
        canLoadMore: true,
        nextCursor: null
      },
      {
        sectionKey: 'worker_team_recommendations',
        title: '优秀团队员工',
        items: [],
        canLoadMore: false,
        nextCursor: null
      }
    ];
  }
}
