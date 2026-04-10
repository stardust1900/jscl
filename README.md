

# jscl

江苏联赛数据查看应用

## 项目简介

jscl 是一个 Flutter 开发的江苏联赛数据查看应用，用于展示足球联赛的比赛信息、球队积分榜和射手榜数据。应用涵盖了江苏省13个城市的足球队伍信息，包括常州、淮安、连云港、南京、南通、宿迁、苏州、泰州、无锡、徐州、盐城、扬州和镇江。

## 功能特性

- **比赛查看**：查看联赛比赛日程和比赛结果
- **积分榜**：查看各球队的积分排名和胜负情况
- **射手榜**：查看球员进球数和排名

## 技术栈

- Flutter
- Dart

## 运行要求

- Flutter SDK (>=2.0.0)
- Dart SDK (>=2.0.0)

## 安装说明

1. 克隆项目到本地：
```bash
git clone https://gitee.com/wangyidao/jscl.git
```

2. 进入项目目录：
```bash
cd jscl
```

3. 获取依赖包：
```bash
flutter pub get
```

4. 运行应用：
```bash
flutter run
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── models/                # 数据模型
│   ├── goal_scorer.dart   # 射手数据模型
│   ├── league_data.dart  # 联赛数据模型
│   ├── match.dart        # 比赛数据模型
│   └── team_standings.dart # 球队积分模型
├── pages/                 # 页面
│   ├── goal_scorers_page.dart # 射手榜页面
│   ├── matches_page.dart     # 比赛页面
│   └── standings_page.dart   # 积分榜页面
└── services/             # 服务
    └── data_service.dart # 数据服务
```

## 参与贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

本项目仅供学习交流使用。