// Chart Initialization Functions

function initGlycemiaChart() {
    const ctx = document.getElementById('glycemiaChart');
    if (!ctx) return;
    
    // Sample data for the chart
    const labels = [];
    const data = [];
    
    // Generate data for the last 14 days
    for (let i = 13; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        labels.push(date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' }));
        
        // Random data between 1.0 and 2.0
        data.push((Math.random() * 1.0 + 1.0).toFixed(2));
    }
    
    // Create the chart
    function initGlycemiaChart() {
    const ctx = document.getElementById('glycemiaChart');
    if (!ctx) return;
    
    // Générer des données pour les 5 dernières années (par mois)
    const labels = [];
    const data = [];
    const now = new Date();
    
    for (let i = 59; i >= 0; i--) {
        const date = new Date();
        date.setMonth(date.getMonth() - i);
        labels.push(date.toLocaleDateString('fr-FR', { month: 'short', year: 'numeric' }));
        
        // Valeurs aléatoires mais avec une tendance réaliste
        const baseValue = 1.2 + Math.sin(i/10) * 0.3;
        const randomVariation = (Math.random() * 0.4) - 0.2;
        data.push(parseFloat((baseValue + randomVariation).toFixed(2)));
    }
    
    // Créer le graphique avec les nouvelles données
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Glycémie (g/dl)',
                data: data,
                backgroundColor: 'rgba(44, 123, 229, 0.1)',
                borderColor: 'rgba(44, 123, 229, 1)',
                borderWidth: 2,
                tension: 0.4,
                fill: true,
                pointBackgroundColor: 'rgba(44, 123, 229, 1)',
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    callbacks: {
                        label: function(context) {
                            return `${context.dataset.label}: ${context.parsed.y} g/dl`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    min: 1.0,
                    max: 2.0,
                    ticks: {
                        stepSize: 0.2,
                        callback: function(value) {
                            return value + ' g/dl';
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// Initialize all charts when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initGlycemiaChart();
});
}