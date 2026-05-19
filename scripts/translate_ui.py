import os
import sys
import re

def main():
    print("=== Antigravity 2.0 UI Translator ===")
    
    # Paths
    scratch_dir = r"C:\Users\Administrator\.gemini\antigravity\brain\a12d81c7-05e0-4def-b7bc-6e8543fed692\scratch"
    input_file = os.path.join(scratch_dir, "ui_main.js")
    
    appdata = os.environ.get("APPDATA")
    if not appdata:
        print("Error: APPDATA environment variable not found.")
        sys.exit(1)
        
    output_dir = os.path.join(appdata, "Antigravity")
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, "zh_cn_ui_main.js")
    
    if not os.path.exists(input_file):
        print(f"Error: Input file {input_file} not found.")
        sys.exit(1)
        
    print(f"Reading from: {input_file}")
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    # Define string translation mapping
    # Note: We must be very precise to match JSON property keys, arrays, or JSX definitions
    translations = {
        # Navigation / Sidebars
        'label:"New Conversation"': 'label:"新建对话"',
        'label:"Create Project"': 'label:"创建项目"',
        'label:"Command Palette"': 'label:"命令面板"',
        'label:"Toggle Fullscreen"': 'label:"切换全屏"',
        'label:"Zoom In"': 'label:"放大"',
        'label:"Zoom Out"': 'label:"缩小"',
        'label:"Reset Zoom"': 'label:"重置缩放"',
        'label:"Toggle Developer Tools"': 'label:"开发者工具"',
        'label:"Minimize"': 'label:"最小化"',
        'label:"Maximize"': 'label:"最大化"',
        'label:"Close"': 'label:"关闭"',
        'label:"About"': 'label:"关于"',
        'label:"Check for Updates"': 'label:"检查更新"',
        
        'title:"File"': 'title:"文件"',
        'title:"View"': 'title:"视图"',
        'title:"Window"': 'title:"窗口"',
        
        # Sidebar section labels
        '"New Conversation"': '"新建对话"',
        '"Scheduled Tasks"': '"计划任务"',
        '"Conversation History"': '"历史对话"',
        '"Projects"': '"项目"',
        '"No conversations yet"': '"暂无历史对话"',
        '"Settings"': '"设置"',
        
        # Chat input placeholder
        '"Ask anything, @ to mention"': '"问任何问题，输入 @ 提及"',
        '", / for actions"': '"，输入 / 执行操作"',
        'aria-label:"Message input"': 'aria-label:"消息输入框"',
        
        # Settings Screens
        '"Project General"': '"项目常规"',
        '"Project Folders"': '"项目文件夹"',
        '"Project Agent"': '"项目智能体"',
        '"Account"': '"账户"',
        '"Google Drive"': '"谷歌云端硬盘"',
        '"General"': '"通用"',
        '"Theme"': '"主题"',
        '"Keyboard Shortcuts"': '"快捷键"',
        '"Permissions"': '"权限"',
        '"No project selected or project management not available."': '"未选择项目，或项目管理不可用。"',
        '"Open Settings"': '"打开设置"',
        '"Open Keyboard Shortcuts"': '"打开快捷键列表"',
        '"No agents running"': '"当前没有运行中的智能体"',
        
        # Project Initializer Dialog
        '"Getting started with a Project"': '"项目入门指南"',
        '"Now that you\'ve created a project, configure your project\'s agent settings or start a conversation."': '"项目创建成功！现在可以配置项目智能体设置，或者直接开始对话。"',
        '"Learn more"': '"了解更多"',
        '"Learn More"': '"了解更多"',
        
        # Buttons & Actions
        '"Submit"': '"提交"',
        '"Continue"': '"继续"',
        '"Cancel"': '"取消"',
        '"Quit"': '"退出"',
        '"Approve"': '"批准"',
        '"Reject"': '"拒绝"',
        '"Allow"': '"允许"',
        '"Deny"': '"拒绝"',
        
        # Agent execution statuses
        '"Completed"': '"已完成"',
        '"Task"': '"任务"',
        '"running"': '"运行中"',
        '"Running"': '"运行中"',
        '"completed"': '"已完成"',
        '"Approved"': '"已批准"',
        '"Requested change"': '"请求变更"',
        '"Denied"': '"已拒绝"',
        
        # Header / Status titles
        '"Action Required"': '"需要操作"',
        '"Completed Operations"': '"已完成操作"',
        '"Walkthrough"': '"任务演练"',
        '"Review"': '"评审"',
        '"Wait"': '"等待"',
    }
    
    print("Applying translations...")
    replaced_count = 0
    for original, translated in translations.items():
        if original in content:
            content = content.replace(original, translated)
            replaced_count += 1
        else:
            # Try single quotes if double quotes mismatch
            alt_original = original.replace('"', "'")
            alt_translated = translated.replace('"', "'")
            if alt_original in content:
                content = content.replace(alt_original, alt_translated)
                replaced_count += 1
            
    print(f"Replaced {replaced_count} of {len(translations)} strings.")
    
    # Save the modified file
    print(f"Writing to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Translation completed successfully!")

if __name__ == "__main__":
    main()
