/**
 * NumberTrainer - 听力练习生成器
 * 移植自 iOS 版本的 NumberTrainer.swift
 */
class NumberTrainer {
    constructor() {
        // 游戏模式
        this.modes = {
            number: { name: 'Chiffres (数字)', icon: '🔢' },
            phone: { name: 'Tél (电话)', icon: '📱' },
            price: { name: 'Prix (价格)', icon: '💰' },
            time: { name: 'Heure (时间)', icon: '🕐' },
            year: { name: 'Année (年份)', icon: '📅' },
            month: { name: 'Mois (月份)', icon: '🗓️' },
            train: { name: 'Train (火车号)', icon: '🚆' },
            flight: { name: 'Vol (航班号)', icon: '✈️' }
        };

        // 当前状态
        this.currentMode = this.loadSetting('gameMode', 'number');
        this.maxRange = parseInt(this.loadSetting('maxRange', '100'));
        this.currentDisplay = '';
        this.speakableContent = '';
        this.isRevealed = false;

        // 月份数据
        this.monthsWithDays = [
            { name: 'janvier', days: 31 },
            { name: 'février', days: 28 },
            { name: 'mars', days: 31 },
            { name: 'avril', days: 30 },
            { name: 'mai', days: 31 },
            { name: 'juin', days: 30 },
            { name: 'juillet', days: 31 },
            { name: 'août', days: 31 },
            { name: 'septembre', days: 30 },
            { name: 'octobre', days: 31 },
            { name: 'novembre', days: 30 },
            { name: 'décembre', days: 31 }
        ];

        // 航空公司代码
        this.airlines = [
            ['AF', 'Air France'],
            ['EK', 'Emirates'],
            ['BA', 'British Airways'],
            ['LH', 'Lufthansa'],
            ['KL', 'KLM']
        ];

        // 火车类型
        this.trainTypes = ['TGV', 'Intercités', 'TER'];
    }

    /**
     * 生成新题目
     * @param {boolean} speakNow - 是否立即播放语音
     */
    generateNew(speakNow = true) {
        this.isRevealed = false;

        switch (this.currentMode) {
            case 'number':
                this.generateNumber();
                break;
            case 'phone':
                this.generatePhone();
                break;
            case 'price':
                this.generatePrice();
                break;
            case 'time':
                this.generateTime();
                break;
            case 'year':
                this.generateYear();
                break;
            case 'month':
                this.generateMonth();
                break;
            case 'train':
                this.generateTrain();
                break;
            case 'flight':
                this.generateFlight();
                break;
        }

        if (speakNow) {
            this.replay();
        }
    }

    // ========== 各模式生成逻辑 ==========

    generateNumber() {
        const num = this.randomInt(0, this.maxRange);
        this.currentDisplay = `${num}`;
        this.speakableContent = `${num}`;
    }

    generatePhone() {
        const prefix = Math.random() < 0.5 ? '06' : '07';
        const parts = [prefix];
        for (let i = 0; i < 4; i++) {
            parts.push(String(this.randomInt(0, 99)).padStart(2, '0'));
        }
        this.currentDisplay = parts.join(' ');
        this.speakableContent = parts.join(', ');
    }

    generatePrice() {
        const euro = this.randomInt(1, 100);
        const cent = this.randomInt(0, 99);
        this.currentDisplay = `${euro},${String(cent).padStart(2, '0')} €`;
        this.speakableContent = `${euro} euros ${cent}`;
    }

    generateTime() {
        const hour = this.randomInt(0, 23);
        const minute = this.randomInt(0, 59);
        this.currentDisplay = `${String(hour).padStart(2, '0')}h${String(minute).padStart(2, '0')}`;

        if (minute === 0) {
            this.speakableContent = `${hour} heures pile`;
        } else if (minute === 30) {
            this.speakableContent = `${hour} heures et demie`;
        } else {
            this.speakableContent = `${hour} heures ${minute}`;
        }
    }

    generateYear() {
        const year = this.randomInt(1950, 2030);
        this.currentDisplay = `${year}`;
        this.speakableContent = `${year}`;
    }

    generateMonth() {
        const month = this.monthsWithDays[this.randomInt(0, 11)];
        const day = this.randomInt(1, month.days);

        this.currentDisplay = `le ${day} ${month.name}`;

        if (day === 1) {
            this.speakableContent = `le premier ${month.name}`;
        } else {
            this.speakableContent = `le ${day} ${month.name}`;
        }
    }

    generateTrain() {
        const trainType = this.trainTypes[this.randomInt(0, 2)];
        const number = this.randomInt(1000, 9999);
        this.currentDisplay = `${trainType} ${number}`;
        this.speakableContent = `${trainType}, ${number}`;
    }

    generateFlight() {
        const airline = this.airlines[this.randomInt(0, 4)];
        const flightNum = this.randomInt(10, 9999);
        this.currentDisplay = `${airline[0]} ${flightNum}`;

        // 逐字母读航空公司代码
        const code = airline[0].split('').join(', ');
        this.speakableContent = `${code}, ${flightNum}`;
    }

    // ========== 控制方法 ==========

    replay() {
        speechManager.speak(this.speakableContent);
    }

    reveal() {
        this.isRevealed = true;
    }

    setMode(mode) {
        this.currentMode = mode;
        this.saveSetting('gameMode', mode);
    }

    setMaxRange(range) {
        this.maxRange = range;
        this.saveSetting('maxRange', range.toString());
    }

    // ========== 辅助方法 ==========

    randomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    loadSetting(key, defaultValue) {
        return localStorage.getItem(`chiffre_${key}`) || defaultValue;
    }

    saveSetting(key, value) {
        localStorage.setItem(`chiffre_${key}`, value);
    }

    /**
     * 获取模式描述
     */
    getModeDescription(mode) {
        const descriptions = {
            phone: '生成随机的法国手机号格式\n(06/07 开头)',
            price: '练习含小数点的价格表达\n(如 12,50 €)',
            time: '练习 24 小时制时间表达\n(如 14h30)',
            year: '练习历史年份或近期年份\n(1950 - 2030)',
            month: '练习日期+月份表达\n(如 le 15 janvier)',
            train: '练习法国火车号码\n(TGV, Intercités, TER)',
            flight: '练习国际航班号\n(如 AF 1234, EK 73)'
        };
        return descriptions[mode] || '';
    }
}
