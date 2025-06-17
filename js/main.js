// DOM Elements
const loginForm = document.getElementById('loginForm');
const emergencyButton = document.getElementById('emergencyButton');
const userMessageInput = document.getElementById('userMessage');
const sendMessageButton = document.getElementById('sendMessage');
const chatMessages = document.getElementById('chatMessages');

// Login Form Submission
if (loginForm) {
    loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        
        // Basic validation
        if (!email || !password) {
            alert('Veuillez remplir tous les champs');
            return;
        }
        
        // In a real app, you would send this to your backend
        console.log('Login attempt with:', email, password);
        
        // Redirect to dashboard (simulated)
        window.location.href = './dashboard.html';
        // Simulate successful login
    });
}

// Emergency Button
if (emergencyButton) {
    emergencyButton.addEventListener('click', function() {
        if (confirm('Êtes-vous sûr de vouloir envoyer une alerte d\'urgence ? Votre localisation sera partagée avec les services d\'urgence.')) {
            // In a real app, this would trigger an emergency protocol
            alert('Alerte d\'urgence envoyée ! Les services ont été notifiés.');
            
            // Simulate sending location
            navigator.geolocation.getCurrentPosition(position => {
                console.log('Emergency location:', position.coords.latitude, position.coords.longitude);
            }, error => {
                console.error('Error getting location:', error);
            });
        }
    });
}

// Chatbot Functionality
if (userMessageInput && sendMessageButton && chatMessages) {
    // Send message when button is clicked
    sendMessageButton.addEventListener('click', sendMessage);
    
    // Send message when Enter key is pressed
    userMessageInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
    
    function sendMessage() {
        const message = userMessageInput.value.trim();
        if (!message) return;
        
        // Add user message to chat
        addMessage(message, 'user');
        userMessageInput.value = '';
        
        // Simulate bot response after a delay
        setTimeout(() => {
            const botResponse = getBotResponse(message);
            addMessage(botResponse, 'bot');
            
            // Scroll to bottom of chat
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }, 1000);
    }
    
    function addMessage(text, sender) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;
        
        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        contentDiv.innerHTML = `<p>${text}</p>`;
        
        const timeDiv = document.createElement('div');
        timeDiv.className = 'message-time';
        
        const now = new Date();
        timeDiv.textContent = `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`;
        
        messageDiv.appendChild(contentDiv);
        messageDiv.appendChild(timeDiv);
        
        chatMessages.appendChild(messageDiv);
        
        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
    
    function getBotResponse(message) {
        // Simple response logic - in a real app, this would connect to an AI service
        const lowerMessage = message.toLowerCase();
        
        if (lowerMessage.includes('maux') || lowerMessage.includes('tête')) {
            return "Les maux de tête peuvent avoir plusieurs causes. Avez-vous pris votre tension artérielle récemment ?";
        } else if (lowerMessage.includes('fièvre')) {
            return "Quelle est votre température actuelle ? Une fièvre persistante peut nécessiter une consultation médicale.";
        } else if (lowerMessage.includes('vertige') || lowerMessage.includes('étourdissement')) {
            return "Les vertiges peuvent être liés à la tension, à l'hydratation ou à d'autres facteurs. Êtes-vous bien hydraté ?";
        } else if (lowerMessage.includes('médicament') || lowerMessage.includes('pilule')) {
            return "N'oubliez pas de prendre vos médicaments comme prescrit par votre médecin. Voulez-vous que je vous rappelle votre prochain médicament ?";
        } else {
            return "Je comprends que vous vous sentez mal. Pouvez-vous me donner plus de détails sur vos symptômes pour que je puisse mieux vous aider ?";
        }
    }
}

function initMap() {
    if (document.getElementById('map')) {
        const dakar = { lat: 14.7167, lng: -17.4677 };
        const map = new google.maps.Map(document.getElementById('map'), {
            zoom: 12,
            center: dakar,
            styles: [
                {
                    "featureType": "poi.medical",
                    "elementType": "geometry",
                    "stylers": [
                        {
                            "color": "#f5f5f5"
                        }
                    ]
                },
                {
                    "featureType": "poi.medical",
                    "elementType": "labels.icon",
                    "stylers": [
                        {
                            "color": "#e63757"
                        },
                        {
                            "visibility": "on"
                        }
                    ]
                }
            ]
        });
        
        new google.maps.Marker({
            position: dakar,
            map: map,
            title: "Votre position",
            icon: {
                url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png"
            }
        });
        
        const hospitals = [
            {
                name: "Centre Hospitalier National Universitaire de FANN",
                location: { lat: 14.7245, lng: -17.4582 }
            },
            {
                name: "Hôpital Général de Grand Yoff",
                location: { lat: 14.7392, lng: -17.4531 }
            },
            {
                name: "Hôpital Principal de Dakar",
                location: { lat: 14.6769, lng: -17.4376 }
            }
        ];
        
        hospitals.forEach(hospital => {
            new google.maps.Marker({
                position: hospital.location,
                map: map,
                title: hospital.name,
                icon: {
                    url: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"
                }
            });
        });
    }
}

function initCharts() {
    if (document.getElementById('glycemiaChart')) {
        const ctx = document.getElementById('glycemiaChart').getContext('2d');
        

        const labels = ['15/06', '14/06', '13/06', '12/06', '11/06', '10/06', '09/06'];
        const data = [1.28, 1.35, 1.42, 1.30, 1.25, 1.38, 1.45];
        
        const chart = new Chart(ctx, {
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
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 1.0,
                        max: 2.0,
                        ticks: {
                            stepSize: 0.2
                        }
                    }
                }
            }
        });
    }
}

document.addEventListener('DOMContentLoaded', function() {
    initCharts();
    

    if (document.getElementById('date')) {
        const today = new Date();
        const dateStr = today.toISOString().split('T')[0];
        document.getElementById('date').value = dateStr;
    }
    

    if (document.getElementById('time')) {
        const now = new Date();
        const hours = now.getHours().toString().padStart(2, '0');
        const minutes = now.getMinutes().toString().padStart(2, '0');
        document.getElementById('time').value = `${hours}:${minutes}`;
    }
});

if (window.location.pathname.includes('dashboard.html')) {
    document.title = 'Santé+360 - Tableau de Bord';
} else if (window.location.pathname.includes('profil.html')) {
    document.title = 'Santé+360 - Profil';
} else if (window.location.pathname.includes('symptomes.html')) {
    document.title = 'Santé+360 - Symptômes';
} else if (window.location.pathname.includes('chatbot.html')) {
    document.title = 'Santé+360 - Chatbot';
} else if (window.location.pathname.includes('urgence.html')) {
    document.title = 'Santé+360 - Urgence';
}

// Gestion des contacts d'urgence
if (document.getElementById('addContactBtn')) {
    const contacts = [
        { name: "Dr. FAYE", relation: "Diabétologue", phone: "+221 77 123 45 67" }
    ];
    
    function renderContacts() {
        const list = document.getElementById('emergencyContactsList');
        list.innerHTML = '';
        
        contacts.forEach((contact, index) => {
            const contactItem = document.createElement('div');
            contactItem.className = 'contact-item';
            contactItem.innerHTML = `
                <div class="contact-info">
                    <h4>${contact.name}</h4>
                    <p>${contact.relation}</p>
                    <p><i class="fas fa-phone"></i> ${contact.phone}</p>
                </div>
                <div class="contact-actions">
                    <button class="btn-icon edit-contact" data-index="${index}">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-icon delete-contact" data-index="${index}">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            list.appendChild(contactItem);
        });
    }
    
    document.getElementById('addContactBtn').addEventListener('click', function() {
        document.getElementById('contactForm').style.display = 'block';
    });
    
    document.getElementById('cancelContactBtn').addEventListener('click', function() {
        document.getElementById('contactForm').style.display = 'none';
    });
    
    document.getElementById('saveContactBtn').addEventListener('click', function() {
        const name = document.getElementById('contactName').value;
        const relation = document.getElementById('contactRelation').value;
        const phone = document.getElementById('contactPhone').value;
        
        if (name && relation && phone) {
            contacts.push({ name, relation, phone });
            renderContacts();
            document.getElementById('contactForm').style.display = 'none';
            // Réinitialiser le formulaire
            document.getElementById('contactName').value = '';
            document.getElementById('contactRelation').value = '';
            document.getElementById('contactPhone').value = '';
        } else {
            alert('Veuillez remplir tous les champs');
        }
    });
    
    // Écouteurs pour les boutons edit/delete
    document.getElementById('emergencyContactsList').addEventListener('click', function(e) {
        if (e.target.closest('.delete-contact')) {
            const index = e.target.closest('.delete-contact').dataset.index;
            contacts.splice(index, 1);
            renderContacts();
        }
    });
    
    renderContacts();
}