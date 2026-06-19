(require 'ox-html)

(defun my-org-html-postprocess-filter (text backend info)
  (if (org-export-derived-backend-p backend 'html)
      (let* ((processed text)
             ;; 1. Replace TOC Title
             (processed (replace-regexp-in-string
                         "<h2>\\(Table of Contents\\|&Iacute;ndice\\|Índice\\)</h2>"
                         "<h2 class=\"title\">Sumário</h2>"
                         processed))
             ;; 2. Check for carousel
             (has-carousel (string-match-p "class=\"CARROSSEL\"" processed)))
        (if has-carousel
            (let ((css "
<style>
.custom-carousel-wrapper {
  position: relative;
  max-width: 100%;
  margin: 1.5em auto;
  overflow: hidden;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  background-color: #f9f9f9;
  border: 1px solid #eaeaea;
}
.custom-carousel-slides {
  display: flex;
  transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  width: 100%;
}
.custom-carousel-slide {
  min-width: 100%;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 10px;
}
.custom-carousel-slide img {
  display: block;
  max-width: 100%;
  height: auto;
  border-radius: 6px;
  user-select: none;
}
.custom-carousel-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  color: #333;
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 12px 16px;
  cursor: pointer;
  border-radius: 50%;
  font-size: 18px;
  font-weight: bold;
  transition: all 0.3s ease;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}
.custom-carousel-btn:hover {
  background: rgba(255, 255, 255, 0.85);
  color: #000;
  box-shadow: 0 4px 18px rgba(0,0,0,0.15);
}
.custom-carousel-btn.prev {
  left: 20px;
}
.custom-carousel-btn.next {
  right: 20px;
}
.custom-carousel-dots {
  position: absolute;
  bottom: 15px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
  z-index: 10;
}
.custom-carousel-dot {
  width: 10px;
  height: 10px;
  background-color: rgba(0, 0, 0, 0.25);
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
}
.custom-carousel-dot.active {
  background-color: #3b82f6;
  transform: scale(1.2);
  box-shadow: 0 0 8px rgba(59, 130, 246, 0.5);
}
@media (prefers-color-scheme: dark) {
  .custom-carousel-wrapper {
    background-color: #1e1e24;
    border-color: #2e2e38;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.4);
  }
  .custom-carousel-btn {
    background: rgba(0, 0, 0, 0.25);
    color: #eee;
    border-color: rgba(255, 255, 255, 0.1);
  }
  .custom-carousel-btn:hover {
    background: rgba(255, 255, 255, 0.15);
    color: #fff;
  }
  .custom-carousel-dot {
    background-color: rgba(255, 255, 255, 0.3);
  }
  .custom-carousel-dot.active {
    background-color: #60a5fa;
  }
}
</style>
")
                  (js "
<script>
document.addEventListener('DOMContentLoaded', function() {
  const carousels = document.querySelectorAll('.CARROSSEL, .carrossel');
  carousels.forEach(function(carousel) {
    const images = carousel.querySelectorAll('img');
    if (images.length === 0) return;
    
    const wrapper = document.createElement('div');
    wrapper.className = 'custom-carousel-wrapper';
    
    const slidesContainer = document.createElement('div');
    slidesContainer.className = 'custom-carousel-slides';
    
    const dotsContainer = document.createElement('div');
    dotsContainer.className = 'custom-carousel-dots';
    
    images.forEach(function(img, index) {
      const slide = document.createElement('div');
      slide.className = 'custom-carousel-slide';
      
      const cloneImg = img.cloneNode(true);
      cloneImg.style.maxWidth = img.getAttribute('width') || '100%';
      cloneImg.removeAttribute('width');
      
      slide.appendChild(cloneImg);
      slidesContainer.appendChild(slide);
      
      const dot = document.createElement('span');
      dot.className = 'custom-carousel-dot' + (index === 0 ? ' active' : '');
      dot.setAttribute('data-index', index);
      dotsContainer.appendChild(dot);
    });
    
    const prevBtn = document.createElement('button');
    prevBtn.className = 'custom-carousel-btn prev';
    prevBtn.innerHTML = '&#10094;';
    
    const nextBtn = document.createElement('button');
    nextBtn.className = 'custom-carousel-btn next';
    nextBtn.innerHTML = '&#10095;';
    
    wrapper.appendChild(slidesContainer);
    wrapper.appendChild(prevBtn);
    wrapper.appendChild(nextBtn);
    wrapper.appendChild(dotsContainer);
    
    carousel.innerHTML = '';
    carousel.appendChild(wrapper);
    
    let currentIndex = 0;
    const totalSlides = images.length;
    const dots = dotsContainer.querySelectorAll('.custom-carousel-dot');
    
    function updateCarousel() {
      slidesContainer.style.transform = 'translateX(-' + (currentIndex * 100) + '%)';
      dots.forEach(function(dot, idx) {
        if (idx === currentIndex) {
          dot.classList.add('active');
        } else {
          dot.classList.remove('active');
        }
      });
    }
    
    prevBtn.addEventListener('click', function(e) {
      e.preventDefault();
      currentIndex = (currentIndex - 1 + totalSlides) % totalSlides;
      updateCarousel();
    });
    
    nextBtn.addEventListener('click', function(e) {
      e.preventDefault();
      currentIndex = (currentIndex + 1) % totalSlides;
      updateCarousel();
    });
    
    dots.forEach(function(dot) {
      dot.addEventListener('click', function(e) {
        e.preventDefault();
        currentIndex = parseInt(dot.getAttribute('data-index'), 10);
        updateCarousel();
      });
    });
  });
});
</script>
"))
              ;; Inject CSS in <head>
              (setq processed (replace-regexp-in-string
                               "</head>"
                               (concat css "\n</head>")
                               processed))
              ;; Inject JS at </body>
              (setq processed (replace-regexp-in-string
                               "</body>"
                               (concat js "\n</body>")
                               processed))
              processed)
          processed))
    text))

(add-to-list 'org-export-filter-final-output-functions 'my-org-html-postprocess-filter)
