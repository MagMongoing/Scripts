### archer + inception上线审核项目钉钉通知脚本
当前使用的版本没有钉钉通知的功能，邮件通知过于不便，由于能力有限，暂时使用外部脚本检查工单的提交状态，通过钉钉机器人来通知相关人员。

脚本为每分钟运行一次，检查最近一分钟内有状态变更的工单，将工单发起人，工单名称，工单状态等发往钉钉机器人。

> 若同一工单在一分钟之内有多次变更，机器人仅捕获最后一次变更状态，暂时这点不影响通知使用

python版本为3.6, 需要安装的依赖：
```
pip install dingtalkchatbot
```
archer数据库sql_workflow表增加随更新而更新的时间字段:
```
alter table archer.sql_workflow add `ding_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```
