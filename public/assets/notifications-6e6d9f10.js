// Real-Time Notification Bell Counter Listener
document.addEventListener('DOMContentLoaded', () => {
  const userId = document.querySelector('meta[name="current-user-id"]')?.content;
  if (!userId) return;

  const badge = document.querySelector('.notif-bell-badge');

  window.incrementNotificationBell = function() {
    if (badge) {
      let count = parseInt(badge.textContent || '0', 10);
      if (isNaN(count)) count = 0;
      badge.textContent = count + 1;
      badge.style.display = 'inline-flex';
    }
  };
});
