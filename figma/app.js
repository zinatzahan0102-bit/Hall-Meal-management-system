const screenName = document.body.dataset.screen;

const navItems = document.querySelectorAll('[data-nav]');
navItems.forEach((item) => {
  if (item.dataset.nav === screenName) {
    item.classList.add('active');
  }
});

const copyButtons = document.querySelectorAll('[data-copy]');
copyButtons.forEach((button) => {
  button.addEventListener('click', async () => {
    const value = button.getAttribute('data-copy');
    try {
      await navigator.clipboard.writeText(value || '');
      const original = button.textContent;
      button.textContent = 'Copied';
      setTimeout(() => {
        button.textContent = original;
      }, 1200);
    } catch (error) {
      console.warn('Clipboard unavailable', error);
    }
  });
});
