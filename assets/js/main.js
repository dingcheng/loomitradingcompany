// Loomi Company — interactivity
(() => {
  const header = document.querySelector('.header');
  const toggle = document.querySelector('.nav__toggle');
  const mobile = document.querySelector('.nav__mobile');

  // Scrolled header state
  const onScroll = () => {
    if (!header) return;
    header.classList.toggle('is-scrolled', window.scrollY > 8);
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // Mobile menu toggle
  if (toggle && mobile) {
    toggle.addEventListener('click', () => {
      const open = mobile.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', String(open));
    });
    mobile.addEventListener('click', (e) => {
      if (e.target.tagName === 'A') mobile.classList.remove('is-open');
    });
  }

  // Active nav link
  const page = (document.body.dataset.page || '').trim();
  if (page) {
    document.querySelectorAll('[data-nav]').forEach((link) => {
      if (link.dataset.nav === page) link.classList.add('is-active');
    });
  }

  // Reveal on scroll
  const items = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && items.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    items.forEach((el) => io.observe(el));
  } else {
    items.forEach((el) => el.classList.add('is-visible'));
  }

  // Set year in footer
  document.querySelectorAll('[data-year]').forEach((el) => {
    el.textContent = String(new Date().getFullYear());
  });

  // -----------------------------------------------------------------
  // Language toggle
  // -----------------------------------------------------------------
  // Each page declares its current language via <html lang="..."> and its
  // alternate-language URL via <link rel="alternate" hreflang="..." href="..."> tags.
  // The toggle reads these and remembers the choice in localStorage.
  const currentLang = (document.documentElement.lang || 'en').toLowerCase().startsWith('zh') ? 'zh' : 'en';
  const altLinks = document.querySelectorAll('link[rel="alternate"][hreflang]');
  const altMap = {};
  altLinks.forEach((l) => {
    const hl = (l.getAttribute('hreflang') || '').toLowerCase();
    if (hl.startsWith('zh')) altMap.zh = l.getAttribute('href');
    else if (hl.startsWith('en')) altMap.en = l.getAttribute('href');
  });

  // Persist explicit user preference
  document.querySelectorAll('[data-lang-switch]').forEach((el) => {
    el.addEventListener('click', () => {
      try {
        localStorage.setItem('loomi.lang', el.dataset.langSwitch);
      } catch (_) { /* ignore */ }
    });
  });

  // Mark active language in the toggle
  document.querySelectorAll('.lang-toggle a').forEach((a) => {
    if ((a.dataset.langSwitch || '').toLowerCase() === currentLang) {
      a.classList.add('is-active');
      a.setAttribute('aria-current', 'true');
    }
  });

  // Auto-redirect on first visit based on saved preference or browser language.
  // Only runs on the homepage and only if user has never explicitly chosen.
  try {
    const saved = localStorage.getItem('loomi.lang');
    const isHome = page === 'home';
    if (isHome && !sessionStorage.getItem('loomi.langRedirected')) {
      sessionStorage.setItem('loomi.langRedirected', '1');
      let want = saved;
      if (!want) {
        const browser = (navigator.language || '').toLowerCase();
        want = browser.startsWith('zh') ? 'zh' : 'en';
      }
      if (want && want !== currentLang && altMap[want]) {
        // Only auto-redirect if the user didn't explicitly request this URL
        // via a language toggle click (which sets the preference first).
        if (saved === want) {
          window.location.replace(altMap[want]);
        }
      }
    }
  } catch (_) { /* ignore */ }
})();
