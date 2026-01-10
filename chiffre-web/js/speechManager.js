/**
 * SpeechManager - Web Speech API 封装
 * 使用浏览器原生 TTS 播放法语
 */
class SpeechManager {
    constructor() {
        this.synth = window.speechSynthesis;
        this.voice = null;
        this.rate = 0.9; // 稍慢一点，更清晰
        this.pitch = 1;
        this.volume = 1;
        
        // 加载法语语音
        this.loadVoice();
        
        // 某些浏览器需要等待 voiceschanged 事件
        if (speechSynthesis.onvoiceschanged !== undefined) {
            speechSynthesis.onvoiceschanged = () => this.loadVoice();
        }
    }
    
    /**
     * 加载法语语音
     */
    loadVoice() {
        const voices = this.synth.getVoices();
        
        // 优先查找法语语音
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
            
            console.log('Selected French voice:', this.voice.name);
        } else {
            console.warn('No French voice found, using default voice');
        }
    }
    
    /**
     * 获取可用的法语语音列表
     */
    getAvailableFrenchVoices() {
        const voices = this.synth.getVoices();
        return voices.filter(voice => 
            voice.lang.startsWith('fr') || voice.lang.includes('FR')
        );
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
        utterance.lang = 'fr-FR';
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
