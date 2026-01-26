/**
 * SpeechManager - Web Speech API 封装
 * 使用浏览器原生 TTS 播放法语
 */
class SpeechManager {
    constructor() {
        this.synth = window.speechSynthesis;
        this.voice = null;
        this.rate = parseFloat(localStorage.getItem('chiffre_rate')) || 1.0;
        this.pitch = 1;
        this.volume = 1;
        this.preferredVoiceURI = localStorage.getItem('chiffre_voice_uri');

        // 加载法语语音
        // 某些浏览器需要等待 voiceschanged 事件
        if (speechSynthesis.onvoiceschanged !== undefined) {
            speechSynthesis.onvoiceschanged = () => this.loadVoice();
        }

        // 尝试立即加载
        this.loadVoice();
    }

    /**
     * 加载法语语音
     */
    loadVoice() {
        const voices = this.synth.getVoices();
        if (voices.length === 0) return;

        // 尝试恢复用户偏好
        if (this.preferredVoiceURI) {
            const preferred = voices.find(v => v.voiceURI === this.preferredVoiceURI);
            if (preferred) {
                this.voice = preferred;
                console.log('Restored preferred voice:', this.voice.name);
                // 触发自定义事件通知 UI 更新
                window.dispatchEvent(new CustomEvent('voicesLoaded'));
                return;
            }
        }

        // 否则使用默认策略：优先查找法语语音
        const frenchVoices = voices.filter(voice =>
            voice.lang.startsWith('fr') || voice.lang.includes('FR')
        );

        if (frenchVoices.length > 0) {
            // 优先选择 Amélie 或类似的高质量语音
            this.voice = frenchVoices.find(v =>
                v.name.toLowerCase().includes('amelie') ||
                v.name.toLowerCase().includes('thomas') ||
                v.name.toLowerCase().includes('enhanced')
            ) || frenchVoices[0];

            console.log('Selected default French voice:', this.voice.name);
        } else {
            console.warn('No French voice found, using default voice');
            this.voice = voices[0];
        }

        // 触发自定义事件通知 UI 更新
        window.dispatchEvent(new CustomEvent('voicesLoaded'));
    }

    /**
     * 获取所有可用语音 (且经过简单去重/筛选，主要返回支持法语的或者所有，这里返回所有以便用户选择，但 UI 层可以筛选)
     * 为了简单起见，这里返回所有语音，UI 层决定显示哪些 (通常显示所有法语语音 + 系统默认)
     */
    getVoices() {
        const voices = this.synth.getVoices();
        // 仅返回法语语音，或者全部？通常用户只想选法语语音。
        return voices.filter(voice =>
            voice.lang.startsWith('fr') || voice.lang.includes('FR')
        );
    }

    setVoice(voiceURI) {
        const voices = this.synth.getVoices();
        const selected = voices.find(v => v.voiceURI === voiceURI);
        if (selected) {
            this.voice = selected;
            this.preferredVoiceURI = voiceURI;
            localStorage.setItem('chiffre_voice_uri', voiceURI);
            console.log('User selected voice:', selected.name);
        }
    }

    setRate(rate) {
        this.rate = rate;
        localStorage.setItem('chiffre_rate', rate);
    }

    /**
     * 播放法语文本
     * @param {string} text - 要朗读的文本
     */
    speak(text) {
        // 取消之前的语音
        this.synth.cancel();

        if (!text) return;

        const utterance = new SpeechSynthesisUtterance(text);

        // 设置语音参数
        if (this.voice) {
            utterance.voice = this.voice;
        }
        // 如果强制指定了 voice，lang 可能会自动变为 voice 的 lang，但显式设置更安全
        utterance.lang = this.voice ? this.voice.lang : 'fr-FR';

        utterance.rate = this.rate;
        utterance.pitch = this.pitch;
        utterance.volume = this.volume;

        // 播放
        this.synth.speak(utterance);
    }

    /**
     * 停止当前语音
     */
    stop() {
        this.synth.cancel();
    }

    /**
     * 检查浏览器是否支持语音合成
     */
    static isSupported() {
        return 'speechSynthesis' in window;
    }
}

// 创建全局实例
const speechManager = new SpeechManager();
