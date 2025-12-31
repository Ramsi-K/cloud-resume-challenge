// Visitor Counter Widget
// Multi-cloud deployment support

(function () {
  // API endpoint

  // Multi-cloud API endpoints:
  // AWS: https://api.ramsi.dev/visitor-count
  // GCP: https://us-central1-cloud-resume-challenge-482812.cloudfunctions.net/cloud-resume-challenge-visitor-counter
  // Azure: (planned) https://api.ramsi.dev/visitor-count
  const API_ENDPOINT = 'https://api.ramsi.dev/visitor-count';

  function initVisitorCounter() {
    const sidebarCounter = document.getElementById('visitor-count-sidebar');

    if (!sidebarCounter) {
      // Element not ready yet, try again in 100ms
      setTimeout(initVisitorCounter, 100);
      return;
    }

    // Set loading state
    sidebarCounter.textContent = 'Loading...';

    async function fetchVisitorCount() {
      try {
        // Check if this session has already been counted
        const sessionCounted = sessionStorage.getItem('visitor-counted');

        let response;
        if (!sessionCounted) {
          // First visit in this session - increment counter
          response = await fetch(API_ENDPOINT, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
          });

          // Mark this session as counted
          sessionStorage.setItem('visitor-counted', 'true');
          console.log('New session - counter incremented');
        } else {
          // Already counted in this session - just get current count
          response = await fetch(API_ENDPOINT, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
            },
          });
          console.log('Existing session - counter not incremented');
        }

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Update sidebar counter with formatted number
        if (sidebarCounter && data.count) {
          sidebarCounter.textContent = data.count.toLocaleString();
        } else {
          throw new Error('Invalid response format');
        }

        console.log('Visitor count loaded:', data.count);
      } catch (error) {
        console.error('Error fetching visitor count:', error);

        // Fallback: try to get current count without incrementing
        try {
          const fallbackResponse = await fetch(API_ENDPOINT, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
            },
          });

          if (fallbackResponse.ok) {
            const fallbackData = await fallbackResponse.json();
            if (sidebarCounter && fallbackData.count) {
              sidebarCounter.textContent = fallbackData.count.toLocaleString();
              console.log('Fallback visitor count loaded:', fallbackData.count);
              return;
            }
          }
        } catch (fallbackError) {
          console.error('Fallback request also failed:', fallbackError);
        }

        // Final fallback
        if (sidebarCounter) {
          sidebarCounter.textContent = 'N/A';
        }
      }
    }

    // Call the function when element is ready
    fetchVisitorCount();
  }

  // Start trying to initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initVisitorCounter);
  } else {
    initVisitorCounter();
  }
})();
