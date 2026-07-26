// Vanilla JS drag-and-drop Kanban implementation for StageUp Company Dashboard
document.addEventListener('DOMContentLoaded', () => {
  let dragged = null;

  document.querySelectorAll('.kanban-card').forEach(card => {
    card.addEventListener('dragstart', (e) => {
      dragged = card;
      card.classList.add('dragging');
    });

    card.addEventListener('dragend', () => {
      card.classList.remove('dragging');
      dragged = null;
    });
  });

  document.querySelectorAll('.kanban-drop-zone').forEach(zone => {
    zone.addEventListener('dragover', (e) => {
      e.preventDefault();
      zone.classList.add('drag-over');
    });

    zone.addEventListener('dragleave', () => {
      zone.classList.remove('drag-over');
    });

    zone.addEventListener('drop', (e) => {
      e.preventDefault();
      zone.classList.remove('drag-over');
      if (!dragged) return;

      const targetStatus = zone.dataset.targetStatus;
      const submissionId = dragged.dataset.submissionId;
      if (!targetStatus || !submissionId || targetStatus === 'pending') return;

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

      fetch(`/submissions/${submissionId}/${targetStatus}`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/json'
        }
      }).then(response => {
        if (response.ok) {
          window.location.reload();
        }
      }).catch(err => console.error('Kanban transition error:', err));
    });
  });
});
