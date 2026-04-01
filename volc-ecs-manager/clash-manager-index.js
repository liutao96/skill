#!/usr/bin/env node
/**
 * Clash 代理管理器 - OpenClaw Skill
 * 通过自然语言控制 Clash 代理服务
 */

const { execSync } = require('child_process');

// 命令映射
const COMMAND_MAP = {
    // 启动代理
    start: ['开启', '启动', '打开', '开', 'on', 'start', '开始'],
    // 停止代理
    stop: ['关闭', '停止', '关掉', '关', 'off', 'stop', '结束'],
    // 查看状态
    status: ['状态', '查看', '检查', 'status', 'state', 'info', '情况'],
    // 测试连接
    test: ['测试', '检查连接', 'test', 'ping', '连通'],
    // 查看节点
    nodes: ['节点', '列表', 'nodes', 'list', '查看节点']
};

// 检测意图
function detectIntent(input) {
    const text = input.toLowerCase();

    // 检查是否包含代理/Clash 关键词
    const hasProxyKeyword = /(代理|clash|proxy|vpn)/i.test(text);

    if (!hasProxyKeyword) {
        return null;
    }

    // 匹配命令
    for (const [command, keywords] of Object.entries(COMMAND_MAP)) {
        for (const keyword of keywords) {
            if (text.includes(keyword.toLowerCase())) {
                return command;
            }
        }
    }

    // 默认返回状态
    return 'status';
}

// 执行命令
function executeCommand(command) {
    try {
        let result;
        switch (command) {
            case 'start':
                result = execSync('clash-ctl on', { encoding: 'utf8', timeout: 10000 });
                return {
                    success: true,
                    message: '🚀 代理服务已启动',
                    details: result
                };
            case 'stop':
                result = execSync('clash-ctl off', { encoding: 'utf8', timeout: 10000 });
                return {
                    success: true,
                    message: '🛑 代理服务已停止',
                    details: result
                };
            case 'status':
                result = execSync('clash-ctl status', { encoding: 'utf8', timeout: 10000 });
                return {
                    success: true,
                    message: '📊 代理服务状态',
                    details: result
                };
            case 'test':
                result = execSync('clash-ctl test', { encoding: 'utf8', timeout: 30000 });
                return {
                    success: true,
                    message: '🧪 代理连接测试',
                    details: result
                };
            case 'nodes':
                result = execSync('clash-ctl nodes', { encoding: 'utf8', timeout: 10000 });
                return {
                    success: true,
                    message: '🌐 可用节点列表',
                    details: result
                };
            default:
                return {
                    success: false,
                    message: '❓ 未知命令',
                    details: '支持的命令：开启/关闭/状态/测试/节点'
                };
        }
    } catch (error) {
        return {
            success: false,
            message: '❌ 执行失败',
            details: error.message
        };
    }
}

// 主函数
function main() {
    // 读取输入
    const args = process.argv.slice(2);
    const input = args.join(' ') || '';

    if (!input) {
        console.log(JSON.stringify({
            type: 'text',
            content: '👋 Clash 代理管理器\n\n使用方法：\n• "开启代理" - 启动代理服务\n• "关闭代理" - 停止代理服务\n• "代理状态" - 查看当前状态\n• "测试代理" - 测试连接\n• "查看节点" - 显示节点列表'
        }));
        return;
    }

    // 检测意图
    const intent = detectIntent(input);

    if (!intent) {
        console.log(JSON.stringify({
            type: 'text',
            content: '💡 未检测到代理相关指令\n\n请包含关键词如：代理、Clash、proxy\n\n例如："开启代理"、"查看代理状态"'
        }));
        return;
    }

    // 执行命令
    const result = executeCommand(intent);

    // 输出结果
    console.log(JSON.stringify({
        type: 'text',
        content: result.message + '\n\n```\n' + result.details + '\n```'
    }));
}

main();
