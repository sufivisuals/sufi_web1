document.addEventListener('DOMContentLoaded', () => {

  // --- 1. AMBIENT HERO CANVAS PARTICLES ---
  const canvas = document.getElementById('hero-canvas');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    let particles = [];
    const particleCount = 40;
    
    const resizeCanvas = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    };
    
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();

    class Particle {
      constructor() {
        this.reset();
      }

      reset() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * 2 + 1;
        this.speedX = (Math.random() - 0.5) * 0.25; // slow drift
        this.speedY = (Math.random() - 0.5) * 0.25;
        this.alpha = Math.random() * 0.5 + 0.1;
        this.glow = Math.random() > 0.8;
      }

      update() {
        this.x += this.speedX;
        this.y += this.speedY;

        if (this.x < 0 || this.x > canvas.width || this.y < 0 || this.y > canvas.height) {
          this.reset();
        }
      }

      draw() {
        ctx.save();
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        if (this.glow) {
          ctx.fillStyle = `rgba(197, 168, 128, ${this.alpha})`;
          ctx.shadowBlur = 10;
          ctx.shadowColor = '#c5a880';
        } else {
          ctx.fillStyle = `rgba(255, 255, 255, ${this.alpha * 0.4})`;
        }
        ctx.fill();
        ctx.restore();
      }
    }

    const initParticles = () => {
      particles = [];
      for (let i = 0; i < particleCount; i++) {
        particles.push(new Particle());
      }
    };

    const animateParticles = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      particles.forEach(p => {
        p.update();
        p.draw();
      });
      requestAnimationFrame(animateParticles);
    };

    initParticles();
    animateParticles();
  }

  // --- 2. HEADER SCROLL STATE ---
  const header = document.querySelector('header');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  });

  // --- 3. SCROLL REVEAL (INTERSECTION OBSERVER) ---
  const revealElements = document.querySelectorAll('.reveal');
  const revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        if (entry.target.classList.contains('results-grid')) {
          animateCountUp();
        }
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.1,
    rootMargin: '0px 0px -120px 0px'
  });

  revealElements.forEach(el => revealObserver.observe(el));

  // --- 4. VIDEO MODAL PLAYER CONTROL ---
  const modal = document.getElementById('modal-player');
  const modalBox = document.getElementById('modal-box');
  const modalClose = document.getElementById('modal-close');
  const modalIframe = modal ? modal.querySelector('iframe') : null;
  const modalVideo = modal ? modal.querySelector('video') : null;
  const videoCards = document.querySelectorAll('.reel-card, .video-horizontal-card');

  if (modal && modalBox && modalClose && (modalIframe || modalVideo)) {
    videoCards.forEach(card => {
      card.addEventListener('click', () => {
        const videoUrl = card.getAttribute('data-video');
        
        // Inline Playback Implementation for local mp4 files
        if (videoUrl.endsWith('.mp4')) {
          // If already playing inline, toggle play/pause instead of spawning another
          const existingVideo = card.querySelector('video.inline-video-player');
          if (existingVideo) {
            if (existingVideo.paused) {
              existingVideo.play();
            } else {
              existingVideo.pause();
            }
            return;
          }
          
          // Stop any other active inline videos on the page first
          document.querySelectorAll('video.inline-video-player').forEach(v => {
            const parent = v.parentElement;
            v.remove();
            if (parent) {
              const img = parent.querySelector('img');
              const overlay = parent.querySelector('.reel-overlay');
              const playBtn = parent.querySelector('.reel-play-btn');
              if (img) img.style.opacity = '1';
              if (overlay) overlay.style.opacity = '1';
              if (playBtn) playBtn.style.opacity = '';
            }
          });

          // Create inline HTML5 video element
          const video = document.createElement('video');
          video.src = videoUrl;
          video.className = 'inline-video-player';
          video.controls = true;
          video.autoplay = true;
          video.playsInline = true;
          video.style.position = 'absolute';
          video.style.top = '0';
          video.style.left = '0';
          video.style.width = '100%';
          video.style.height = '100%';
          video.style.objectFit = 'cover';
          video.style.zIndex = '2';
          video.style.borderRadius = '20px';
          video.style.background = '#000';

          // Hide thumbnail and overlays
          const img = card.querySelector('img');
          const overlay = card.querySelector('.reel-overlay');
          const playBtn = card.querySelector('.reel-play-btn');
          if (img) img.style.opacity = '0';
          if (overlay) overlay.style.opacity = '0';
          if (playBtn) playBtn.style.opacity = '0';

          // Listen for when video ends to restore UI
          video.addEventListener('ended', () => {
            video.remove();
            if (img) img.style.opacity = '1';
            if (overlay) overlay.style.opacity = '1';
            if (playBtn) playBtn.style.opacity = '';
          });

          card.appendChild(video);
          return;
        }

        const isShortForm = card.classList.contains('reel-card');

        // Set vertical configuration for short form reels
        if (isShortForm) {
          modalBox.classList.add('vertical');
        } else {
          modalBox.classList.remove('vertical');
        }

        if (modalVideo) {
          modalVideo.style.display = 'none';
          modalVideo.src = '';
        }
        if (modalIframe) {
          modalIframe.style.display = 'block';
          modalIframe.setAttribute('src', `${videoUrl}?autoplay=1`);
        }
        modal.classList.add('active');
      });
    });

    const closeModal = () => {
      modal.classList.remove('active');
      if (modalIframe) modalIframe.setAttribute('src', '');
      if (modalVideo) {
        modalVideo.pause();
        modalVideo.src = '';
      }
    };

    // Close on click close button
    modalClose.addEventListener('click', closeModal);

    // Close on click backdrop
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeModal();
      }
    });

    // Close on Esc key
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal.classList.contains('active')) {
        closeModal();
      }
    });
  }

  // --- 5. FAQ ACCORDION TRIGGER ---
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const faqHeader = item.querySelector('.faq-header');
    const faqBody = item.querySelector('.faq-body');
    
    faqHeader.addEventListener('click', () => {
      const isActive = item.classList.contains('active');
      
      // Close all open FAQs
      faqItems.forEach(i => {
        i.classList.remove('active');
        i.querySelector('.faq-body').style.maxHeight = '0px';
      });
      
      // Toggle current FAQ
      if (!isActive) {
        item.classList.add('active');
        faqBody.style.maxHeight = `${faqBody.scrollHeight}px`;
      }
    });
  });

  // --- 6. TIMELINE PROGRESS LINE ANIMATION ---
  const timeline = document.querySelector('.growth-timeline-container');
  const progressFill = document.querySelector('.timeline-progress-fill');
  const timelineSteps = document.querySelectorAll('.timeline-step');
  
  if (timeline && progressFill) {
    window.addEventListener('scroll', () => {
      const rect = timeline.getBoundingClientRect();
      const viewportHeight = window.innerHeight;
      
      // Calculate scroll progress percentage through the timeline container
      const start = rect.top - viewportHeight / 2;
      const end = rect.bottom - viewportHeight / 2;
      const total = end - start;
      const progress = Math.min(Math.max(-start / total, 0), 1);
      
      progressFill.style.height = `${progress * 100}%`;
      
      // Toggle active states for individual steps based on position
      timelineSteps.forEach(step => {
        const stepRect = step.getBoundingClientRect();
        if (stepRect.top < viewportHeight / 1.6) {
          step.classList.add('active');
        } else {
          step.classList.remove('active');
        }
      });
    });
  }

  // --- 7. HERO PARALLAX & SCROLL ANIMATIONS ---
  const heroSection = document.getElementById('hero');
  const heroCircle = document.querySelector('.hero-circle-bg');
  const floatingTagWrappers = document.querySelectorAll('.floating-tag-wrapper');
  
  if (heroSection) {
    window.addEventListener('scroll', () => {
      const scrollY = window.scrollY;
      
      // Limit calculations to hero height to save performance
      if (scrollY < 800) {
        // Rotate circular background behind photo in place (kept locked to photo border)
        if (heroCircle) {
          const rotate = scrollY * 0.06; // gentle spin in place
          heroCircle.style.transform = `translate3d(-50%, -50%, 0) rotate(${rotate}deg)`;
        }
        
        // Animate floating tags (different speed directions for floating parallax)
        floatingTagWrappers.forEach((tag, idx) => {
          // Alternative directions and coefficients based on circular positioning
          let speedY, speedX;
          switch(idx) {
            case 0: speedY = -0.11; speedX = 0; break;     // Tag 1 (Top / North)
            case 1: speedY = -0.06; speedX = 0.06; break;  // Tag 2 (Right-Top)
            case 2: speedY = 0.06; speedX = 0.06; break;   // Tag 3 (Right-Bottom)
            case 3: speedY = 0.11; speedX = 0; break;      // Tag 4 (Bottom / South)
            case 4: speedY = 0.06; speedX = -0.06; break;  // Tag 5 (Left-Bottom)
            case 5: speedY = -0.06; speedX = -0.06; break; // Tag 6 (Left-Top)
            default: speedY = -0.05; speedX = 0;
          }
          
          const translateY = scrollY * speedY;
          const translateX = scrollY * speedX;
          
          tag.style.transform = `translate3d(calc(-50% + ${translateX}px), calc(-50% + ${translateY}px), 0)`;
        });
      }
    });
  }

  function animateCountUp() {
    const elements = document.querySelectorAll('#client-results [data-target]');
    const duration = 4500; // 4.5 seconds

    // Animate numbers
    elements.forEach(el => {
      const target = parseInt(el.getAttribute('data-target'), 10);
      const start = 0;
      const startTime = performance.now();

      const updateCount = (currentTime) => {
        const elapsedTime = currentTime - startTime;
        const progress = Math.min(elapsedTime / duration, 1);
        
        // Easing out cubic: f(t) = 1 - (1 - t)^3 for smooth deceleration
        const easeProgress = 1 - Math.pow(1 - progress, 3);
        
        const currentValue = Math.floor(start + easeProgress * (target - start));
        el.textContent = currentValue.toLocaleString();

        if (progress < 1) {
          requestAnimationFrame(updateCount);
        } else {
          el.textContent = target.toLocaleString();
        }
      };

      requestAnimationFrame(updateCount);
    });

    // Animate progress bar widths
    const barFills = document.querySelectorAll('#client-results .bar-fill');
    setTimeout(() => {
      barFills.forEach(bar => {
        const targetWidth = bar.getAttribute('data-width');
        bar.style.width = targetWidth;
      });
    }, 100);
  }

  // --- MOBILE MENU TOGGLE ---
  const menuToggle = document.getElementById('menu-toggle');
  const navMenu = document.querySelector('nav');
  
  if (menuToggle && navMenu) {
    menuToggle.addEventListener('click', () => {
      menuToggle.classList.toggle('active');
      navMenu.classList.toggle('active');
    });
    
    // Close menu when clicking on a link
    navMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        menuToggle.classList.remove('active');
        navMenu.classList.remove('active');
      });
    });
  }

  // --- PAIN POINTS & CARDS SCROLL FOCUS HIGHLIGHT ---
  const scrollHighlightElements = document.querySelectorAll(
    '#struggles .pain-card, ' +
    '#services .service-card, ' +
    '#growth-system .timeline-step, ' +
    '#makeup-artistry .reel-card, ' +
    '#short-form .reel-card, ' +
    '#client-results .phone-container'
  );

  if (scrollHighlightElements.length > 0) {
    const highlightObserverOptions = {
      root: null,
      rootMargin: '-30% 0px -30% 0px',
      threshold: 0.1
    };

    const highlightObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('scroll-active');
        } else {
          entry.target.classList.remove('scroll-active');
        }
      });
    }, highlightObserverOptions);

    scrollHighlightElements.forEach(el => highlightObserver.observe(el));
  }

});
