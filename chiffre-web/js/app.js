/**
 * Chiffre Web - Main Application
 * 主应用逻辑
 */

// 全局变量
let trainer;
let currentPage = 'home';

// DOM 元素缓存
const elements = {};

/**
 * 初始化应用
 */
function initApp() {
    // 检查语音支持
    if (!SpeechManager.isSupported()) {
        alert('您的浏览器不支持语音合成功能，请使用 Chrome、Safari 或 Edge 浏览器。');
    }

    // 初始化 NumberTrainer
    trainer = new NumberTrainer();

    // 缓存 DOM 元素
    cacheElements();

    // 初始化 UI
    initParticles();
    initModeList();
    initReferenceGrids();

    // 绑定事件
    bindEvents();

    // 生成第一题（不播放语音）
    trainer.generateNew(false);
}

/**
 * 缓存 DOM 元素
 */
function cacheElements() {
    elements.homePage = document.getElementById('home-page');
    elements.referencePage = document.getElementById('reference-page');
    elements.settingsPanel = document.getElementById('settings-panel');

    elements.mainCard = document.getElementById('main-card');
    elements.cardContent = document.getElementById('card-content');
    elements.listenIcon = document.getElementById('listen-icon');
    elements.answerDisplay = document.getElementById('answer-display');
    elements.hintText = document.getElementById('hint-text');

    elements.replayBtn = document.getElementById('replay-btn');
    elements.actionBtn = document.getElementById('action-btn');
    elements.settingsBtn = document.getElementById('settings-btn');
    elements.closeSettings = document.getElementById('close-settings');

    elements.modeList = document.getElementById('mode-list');
    elements.rangeSection = document.getElementById('range-section');
    elements.rangeSlider = document.getElementById('range-slider');
    elements.rangeDisplay = document.getElementById('range-display');
    elements.modeDescription = document.getElementById('mode-description');
    elements.descriptionIcon = document.getElementById('description-icon');
    elements.descriptionText = document.getElementById('description-text');

    elements.navBtns = document.querySelectorAll('.nav-btn');
}

/**
 * 初始化光粒子效果
 */
function initParticles() {
    const container = document.getElementById('particles');
    const particleCount = 50;

    for (let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = `${Math.random() * 100}%`;
        particle.style.top = `${Math.random() * 100}%`;
        particle.style.width = `${4 + Math.random() * 8}px`;
        particle.style.height = particle.style.width;
        particle.style.animationDelay = `${Math.random() * 2}s`;
        container.appendChild(particle);
    }
}

/**
 * 初始化模式选择列表
 */
function initModeList() {
    const modeList = elements.modeList;
    modeList.innerHTML = '';

    for (const [key, mode] of Object.entries(trainer.modes)) {
        const pill = document.createElement('button');
        pill.className = `mode-pill ${key === trainer.currentMode ? 'active' : ''}`;
        pill.dataset.mode = key;
        pill.innerHTML = `<span>${mode.icon}</span> ${mode.name}`;
        pill.addEventListener('click', () => selectMode(key));
        modeList.appendChild(pill);
    }

    updateSettingsUI();
}

/**
 * 初始化参考页面的数字网格
 */
function initReferenceGrids() {
    // Les Bases (1-20)
    const basesGrid = document.getElementById('bases-grid');
    for (let i = 1; i <= 20; i++) {
        basesGrid.appendChild(createNumberCell(i));
    }

    // Les Dizaines (30, 40, 50, 60)
    const dizainesGrid = document.getElementById('dizaines-grid');
    [30, 40, 50, 60].forEach(num => {
        dizainesGrid.appendChild(createNumberCell(num));
    });

    // Les Complexes (70-79, 80, 90-99, 100, 1000, ∞)
    const complexesGrid = document.getElementById('complexes-grid');
    for (let i = 70; i <= 79; i++) {
        complexesGrid.appendChild(createNumberCell(i));
    }
    complexesGrid.appendChild(createNumberCell(80));
    for (let i = 90; i <= 99; i++) {
        complexesGrid.appendChild(createNumberCell(i));
    }
    complexesGrid.appendChild(createNumberCell(100, true));
    complexesGrid.appendChild(createNumberCell(1000, true));
    complexesGrid.appendChild(createNumberCell(-1)); // Infinity
}

/**
 * 创建数字单元格
 */
function createNumberCell(num, isLarge = false) {
    const cell = document.createElement('div');
    cell.className = 'number-cell';

    if (num === -1) {
        cell.textContent = '∞';
        cell.classList.add('infinity');
    } else {
        cell.textContent = num;
        if (isLarge || num >= 100) {
            cell.classList.add('large');
        }
    }

    cell.addEventListener('click', () => {
        // 添加按下效果
        cell.classList.add('pressed');
        setTimeout(() => cell.classList.remove('pressed'), 300);

        // 播放发音
        if (num === -1) {
            speechManager.speak("L'infini");
        } else {
            speechManager.speak(`${num}`);
        }
    });

    return cell;
}

/**
 * 绑定事件监听器
 */
function bindEvents() {
    // 主页面事件
    elements.mainCard.addEventListener('click', handleCardClick);
    elements.replayBtn.addEventListener('click', () => trainer.replay());
    elements.actionBtn.addEventListener('click', handleActionClick);

    // 设置面板事件
    elements.settingsBtn.addEventListener('click', openSettings);
    elements.closeSettings.addEventListener('click', closeSettings);

    // 范围滑块
    elements.rangeSlider.addEventListener('input', handleRangeChange);

    // 预设按钮
    document.querySelectorAll('.preset-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const value = parseInt(btn.dataset.value);
            trainer.setMaxRange(value);
            elements.rangeSlider.value = value;
            updateRangeDisplay();
            updatePresetButtons();
            trainer.generateNew(false);
        });
    });

    // 底部导航
    elements.navBtns.forEach(btn => {
        btn.addEventListener('click', () => navigateTo(btn.dataset.page));
    });

    // 点击设置面板外部关闭
    elements.settingsPanel.addEventListener('click', (e) => {
        if (e.target === elements.settingsPanel) {
            closeSettings();
        }
    });
}

/**
 * 处理卡片点击
 */
function handleCardClick() {
    if (!trainer.isRevealed) {
        trainer.replay();
    }
}

/**
 * 处理主按钮点击
 */
function handleActionClick() {
    if (trainer.isRevealed) {
        // Suivant - 生成新题
        trainer.generateNew(true);
        updateMainUI();
    } else {
        // Révéler - 显示答案
        trainer.reveal();
        updateMainUI();
    }
}

/**
 * 选择模式
 */
function selectMode(mode) {
    trainer.setMode(mode);
    trainer.generateNew(false);

    // 更新 UI
    document.querySelectorAll('.mode-pill').forEach(pill => {
        pill.classList.toggle('active', pill.dataset.mode === mode);
    });

    updateSettingsUI();
    updateMainUI();
}

/**
 * 更新设置 UI
 */
function updateSettingsUI() {
    const isNumberMode = trainer.currentMode === 'number';

    // 显示/隐藏范围设置
    elements.rangeSection.style.display = isNumberMode ? 'block' : 'none';

    // 显示/隐藏模式描述
    if (!isNumberMode) {
        elements.modeDescription.classList.remove('hidden');
        elements.descriptionIcon.textContent = trainer.modes[trainer.currentMode].icon;
        elements.descriptionText.textContent = trainer.getModeDescription(trainer.currentMode);
    } else {
        elements.modeDescription.classList.add('hidden');
    }

    updateRangeDisplay();
    updatePresetButtons();
}

/**
 * 更新主界面
 */
function updateMainUI() {
    if (trainer.isRevealed) {
        // 显示答案
        elements.listenIcon.style.display = 'none';
        elements.answerDisplay.classList.remove('hidden');
        elements.answerDisplay.textContent = trainer.currentDisplay;

        // 动态字体大小
        const text = trainer.currentDisplay;
        if (text.length > 10) {
            elements.answerDisplay.style.fontSize = '42px';
        } else if (text.length > 5) {
            elements.answerDisplay.style.fontSize = '64px';
        } else {
            elements.answerDisplay.style.fontSize = '96px';
        }

        elements.hintText.textContent = "C'est ça!";
        elements.actionBtn.textContent = 'Suivant';
        elements.actionBtn.classList.add('revealed');
    } else {
        // 隐藏状态
        elements.listenIcon.style.display = 'block';
        elements.answerDisplay.classList.add('hidden');
        elements.hintText.textContent = 'Écoutez...';
        elements.actionBtn.textContent = 'Révéler';
        elements.actionBtn.classList.remove('revealed');
    }
}

/**
 * 处理范围滑块变化
 */
function handleRangeChange(e) {
    const value = parseInt(e.target.value);
    trainer.setMaxRange(value);
    updateRangeDisplay();
    updatePresetButtons();
}

/**
 * 更新范围显示
 */
function updateRangeDisplay() {
    elements.rangeDisplay.textContent = `0 - ${trainer.maxRange}`;
    elements.rangeSlider.value = trainer.maxRange;
}

/**
 * 更新预设按钮状态
 */
function updatePresetButtons() {
    document.querySelectorAll('.preset-btn').forEach(btn => {
        btn.classList.toggle('active', parseInt(btn.dataset.value) === trainer.maxRange);
    });
}

/**
 * 打开设置面板
 */
function openSettings() {
    elements.settingsPanel.classList.add('active');
}

/**
 * 关闭设置面板
 */
function closeSettings() {
    elements.settingsPanel.classList.remove('active');
}

/**
 * 页面导航
 */
function navigateTo(page) {
    currentPage = page;

    // 更新页面显示
    elements.homePage.classList.toggle('hidden', page !== 'home');
    elements.homePage.classList.toggle('active', page === 'home');
    elements.referencePage.classList.toggle('hidden', page !== 'reference');
    elements.referencePage.classList.toggle('active', page === 'reference');

    // 更新导航按钮状态
    elements.navBtns.forEach(btn => {
        btn.classList.toggle('active', btn.dataset.page === page);
    });

    // 关闭设置面板
    closeSettings();
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', initApp);
