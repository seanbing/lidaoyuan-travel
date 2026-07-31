const stage = document.getElementById("stage");
const startButton = document.getElementById("startButton");
const motionStatus = document.getElementById("motionStatus");
const parallaxLayers = [...document.querySelectorAll(".layer")];
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
// 鼠标视差会持续改写文字、人物、船只和按钮的位移变量。
// 当前封面以稳定展示为主，默认关闭，避免动画结束后鼠标经过页面产生轻微抖动。
const enableParallax = false;

function setParallax(clientX, clientY) {
  if (!enableParallax || reduceMotion.matches) return;

  const rect = stage.getBoundingClientRect();
  const x = (clientX - rect.left) / rect.width - 0.5;
  const y = (clientY - rect.top) / rect.height - 0.5;

  parallaxLayers.forEach((layer) => {
    const depth = Number(layer.dataset.depth || 0.2);
    layer.style.setProperty("--mx", `${x * depth * 18}px`);
    layer.style.setProperty("--my", `${y * depth * 12}px`);
  });
}

stage.addEventListener("pointermove", (event) => {
  setParallax(event.clientX, event.clientY);
});

stage.addEventListener("pointerleave", () => {
  parallaxLayers.forEach((layer) => {
    layer.style.removeProperty("--mx");
    layer.style.removeProperty("--my");
  });
});

window.setTimeout(() => {
  motionStatus.textContent = "画卷已展开，可以开启行旅";
}, reduceMotion.matches ? 20 : 4400);

startButton.addEventListener("click", () => {
  if (stage.classList.contains("leaving")) return;

  stage.classList.add("leaving");
  motionStatus.textContent = "正在进入行旅地图";

  window.setTimeout(
    () => {
      window.location.href = "./gis-map.html";
    },
    reduceMotion.matches ? 0 : 620,
  );
});
