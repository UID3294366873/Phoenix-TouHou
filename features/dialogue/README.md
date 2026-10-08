# 对话功能目录

这个目录包含“读取剧情 JSON → 执行命令 → 更新画面”的完整功能，外部场景只需要装配
`DialogueRunner` 与 `StoryPresenter`。

## 各层职责

- `commands/`：一个命令一个类。命令只读取自己的 `value`，修改运行状态或调用
  `StoryPresenter` 的公开方法。
- `loading/`：把 JSON 转成 `DialogueProgram`，并在加载时建立 anchor 到步骤下标的字典。
- `runtime/`：保存游标、逐命令执行，并根据 `DialogueCommandResult` 决定继续、等待、跳转或结束。
- `presentation/`：唯一允许直接操作背景、角色立绘和对话 UI 的层。
- `presentation/character/`：角色资料与角色显示场景。
- `presentation/ui/`：对话框、选项按钮和文字音效场景。

## 场景接口

`res://app/story/story_scene.tscn` 是组合根场景：

```text
StoryScene
├── Runtime
│   └── DialogueRunner
└── Presentation
    ├── StoryPresenter
    ├── NextSentenceSound
    ├── TransitionLayer
    ├── BackgroundLayer
    │   └── BackgroundView
    └── CharacterUILayer
        ├── CharacterAnchor
        │   └── CharacterView
        └── DialogueUI
```

接口流向固定为：

```text
DialogueUI --玩家输入信号--> StoryScene --resume/choose--> DialogueRunner
DialogueRunner --命令调用--> StoryPresenter --方法调用--> 各显示场景
DialogueRunner --jump 信号--> StoryScene --加载新 JSON--> DialogueRunner
```

`jump` 由 `StoryScene` 编排为“转场遮住画面 → 加载新 JSON → 新文件执行
background → 转场揭开画面”。转场只是表现组件，不是复合剧情命令。

UI 子场景不读取 JSON，命令不查找场景节点，Runner 不直接修改画面。

## 添加一个新命令

例如添加 `{ "shake": 0.3 }`：

1. 在 `commands/` 新建 `shake_command.gd`，继承 `DialogueCommand`。
2. 实现 `execute(state, presenter)`；需要画面效果时，只调用
   `presenter.shake(float(value))`，然后返回 `DialogueCommandResult.proceed()`。
3. 在 `loading/dialogue_command_factory.gd` 的表中加入
   `&"shake": preload("res://features/dialogue/commands/shake_command.gd")`。
4. 在 `StoryPresenter` 增加 `shake()`，由它操作动画节点或专用的效果子场景。
5. 把命令写入离线生成的 JSON，并给 `tests/dialogue/` 增加对应的运行场景。

若命令只修改剧情状态（例如 speaker、expression、goto），不需要给 Presenter 增加方法。
能够由多个基础命令表达的行为应继续在 DrameX 翻译阶段展开，不在游戏里增加复合命令。
