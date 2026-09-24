# v1.0.2

- 倒计时增删立即调用 Settings.setValue 和 sync，避免延迟写入导致重启恢复旧内容。
- 仅缺少配置键时加载默认倒计时；保存空列表后不会重新生成默认项。
- 保留原配置键 `Countdowns/items`，兼容已有倒计时。
- 增加独立配置目录的进程级回归测试，覆盖新增、按钮删除、全部删除及强制退出后重启。

# v1.0.1

- 时钟上方显示日期、星期；下方显示工作日、周末、节假日名称或调休补班。
- 通过 HTTPS IP 定位识别国家、省州、时区。首选 ipwho.is，失败尝试 ipapi.co。
- 内置 holidays 0.105 生成的 2026 年公共假日数据，含 250 个国家和支持的省州，共 874 份日历。
- 节假日计算不依赖 Nexus 服务端。按地区时区每秒更新时间与日期，跨日自动重新计算。
- 每半小时刷新定位，失败五分钟重试；未知地区或未覆盖年份明确提示数据不可用。
- 应用窗口、`NexusQt --version` 和 Debian 安装包统一版本 1.0.1。
- 修正倒计时委托中直接引用 Settings 的作用域错误，统一由组件函数保存增删操作。

数据只覆盖 2026 年，升级年份需使用新版 holidays 重新生成并核验中国调休安排。
国外节日名称使用数据源支持的语言。IP 反映网络出口，代理可能影响定位。

生成日历：`python -m pip install holidays==0.105`，然后执行 `python scripts/generate_calendar.py`。
数据源：https://holidays.readthedocs.io/en/latest/api/
定位文档：https://ipwhois.io/documentation 、https://ipapi.co/api/

实际构建依赖为 Qt 5.15（以 CMakeLists.txt 为准）。
