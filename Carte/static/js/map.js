// map.js - Gestion de la carte complète
function initFullMap() {
    const map = new google.maps.Map(document.getElementById('fullMap'), {
        center: { lat: 14.7167, lng: -17.4677 }, // Dakar
        zoom: 13,
        styles: [
            {
                "featureType": "poi.medical",
                "elementType": "geometry",
                "stylers": [{ "color": "#f5f5f5" }]
            },
            {
                "featureType": "poi.medical",
                "elementType": "labels.icon",
                "stylers": [
                    { "color": "#e63757" },
                    { "visibility": "on" }
                ]
            }
        ]
    });

    // Données des établissements
    const establishments = [
        {
            name: "CHNU de Fann",
            type: "hospital",
            position: { lat: 14.7245, lng: -17.4582 },
            phone: "33 889 10 00",
            services: ["Urgences", "Cardiologie", "Neurologie"],
            opening: "24h/24"
        },
        // Ajoutez d'autres établissements...
    ];

    // Créer les marqueurs
    establishments.forEach(est => {
        const marker = new google.maps.Marker({
            position: est.position,
            map: map,
            title: est.name,
            icon: getMarkerIcon(est.type)
        });

        // InfoWindow
        const infoWindow = new google.maps.InfoWindow({
            content: `
                <div class="map-info-window">
                    <h4>${est.name}</h4>
                    <p><i class="fas fa-phone"></i> ${est.phone}</p>
                    <p><i class="fas fa-clock"></i> ${est.opening}</p>
                    <p><i class="fas fa-stethoscope"></i> ${est.services.join(', ')}</p>
                </div>
            `
        });

        marker.addListener('click', () => {
            infoWindow.open(map, marker);
        });
    });

    // Gestion des filtres
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            // Ici vous filtreriez les marqueurs en fonction du type
        });
    });
}

function getMarkerIcon(type) {
    const icons = {
        hospital: 'http://maps.google.com/mapfiles/ms/icons/blue-dot.png',
        clinic: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png',
        pharmacy: 'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png',
        emergency: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
    };
    return icons[type] || 'http://maps.google.com/mapfiles/ms/icons/red-dot.png';
}