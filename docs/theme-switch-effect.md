# 主题切换圆形扩散效果 - 技术总结

## 核心原理

使用 CSS `mask-image` 在旧主题颜色的遮罩层上"挖洞"，洞逐渐扩大，露出下方已经切换好的新主题内容。

**流程：**

1. 点击按钮 → 立即切换主题（新主题在底层）
2. 创建旧主题颜色的全屏遮罩覆盖页面
3. 遮罩上有一个从点击位置开始的透明圆形"洞"
4. 洞的半径从 0 扩大到 150vmax，逐渐露出新主题
5. 动画完成后移除遮罩

---

## CSS 实现

```css
/* 让自定义属性可以被动画 */
@property --r {
  syntax: '<length>';
  initial-value: 0px;
  inherits: false;
}

/* 遮罩层 */
.theme-transition-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 9999;
  --r: 0px;
  /* 关键：用 radial-gradient 挖洞，圆心透明，外部显示背景色 */
  mask-image: radial-gradient(
    circle at var(--x, 50%) var(--y, 50%),
    transparent var(--r),
    black var(--r)
  );
  -webkit-mask-image: radial-gradient(
    circle at var(--x, 50%) var(--y, 50%),
    transparent var(--r),
    black var(--r)
  );
}

/* 扩散动画 */
.theme-transition-overlay.expanding {
  transition: --r 0.8s ease-in-out;
  --r: 150vmax;
}
```

**关键点：**

- `@property` 声明让 `--r` 变量可以平滑过渡（普通 CSS 变量无法动画）
- `mask-image: radial-gradient(transparent var(--r), black var(--r))` 创建圆形透明区域
- `150vmax` 确保圆形足够大，覆盖任意尺寸屏幕

---

## JavaScript 实现

```javascript
const THEME_KEY = 'theme-preference';

const THEME_COLORS = {
  dark: '#0a0a0a',
  light: '#faf9f7'
};

function initTheme() {
  const savedTheme = localStorage.getItem(THEME_KEY);
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const theme = savedTheme || (prefersDark ? 'dark' : 'light');
  document.documentElement.setAttribute('data-theme', theme);
}

function toggleTheme(event) {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme') || 'dark';
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

  // 1. 移除旧遮罩
  const existingOverlay = document.querySelector('.theme-transition-overlay');
  if (existingOverlay) existingOverlay.remove();

  // 2. 创建遮罩（旧主题颜色）
  const overlay = document.createElement('div');
  overlay.className = 'theme-transition-overlay';
  overlay.style.background = THEME_COLORS[currentTheme];
  document.body.appendChild(overlay);

  // 3. 设置圆心位置（点击位置）
  const x = event.clientX || window.innerWidth - 40;
  const y = event.clientY || 40;
  overlay.style.setProperty('--x', `${x}px`);
  overlay.style.setProperty('--y', `${y}px`);

  // 4. 立即切换主题（藏在遮罩下）
  html.setAttribute('data-theme', newTheme);
  localStorage.setItem(THEME_KEY, newTheme);

  // 5. 下一帧开始扩散动画
  requestAnimationFrame(() => {
    overlay.classList.add('expanding');
  });

  // 6. 动画结束后移除遮罩
  setTimeout(() => overlay.remove(), 850);
}

// 初始化
initTheme();
document.getElementById('theme-toggle').addEventListener('click', toggleTheme);
```

---

## 主题 CSS 变量定义

```css
:root {
  /* 暗色主题（默认） */
  --color-bg-primary: #0a0a0a;
  --color-bg-secondary: #111111;
  --color-text-primary: #e8e6e3;
  /* ... 其他变量 */
}

:root[data-theme="light"] {
  /* 亮色主题 */
  --color-bg-primary: #faf9f7;
  --color-bg-secondary: #f5f4f1;
  --color-text-primary: #1a1a1a;
  /* ... 其他变量 */
}
```

---

## 切换按钮示例

```html
<button id="theme-toggle" aria-label="切换主题">
  <!-- 太阳图标（暗色主题时显示） -->
  <svg class="sun-icon">...</svg>
  <!-- 月亮图标（亮色主题时显示） -->
  <svg class="moon-icon">...</svg>
</button>
```

```css
:root[data-theme="dark"] .sun-icon { display: block; }
:root[data-theme="dark"] .moon-icon { display: none; }
:root[data-theme="light"] .sun-icon { display: none; }
:root[data-theme="light"] .moon-icon { display: block; }
```

---

## 浏览器兼容性

| 特性 | 支持情况 |
|------|----------|
| `@property` | Chrome 85+, Edge 85+, Safari 15.4+ |
| `mask-image` | 需要 `-webkit-` 前缀兼容 Safari |
| CSS 变量 | 现代浏览器均支持 |

**降级方案：** 如果浏览器不支持 `@property`，动画不会生效，但主题切换功能正常。

---

## 复用清单

在新项目中使用，需要：

1. **CSS 部分**
   - `@property --r` 声明
   - `.theme-transition-overlay` 样式
   - 明暗两套主题的 CSS 变量

2. **JavaScript 部分**
   - `THEME_COLORS` 对象（与 CSS 主题背景色一致）
   - `initTheme()` 函数
   - `toggleTheme(event)` 函数

3. **HTML 部分**
   - 切换按钮 `#theme-toggle`
   - `<html>` 标签上的 `data-theme` 属性
