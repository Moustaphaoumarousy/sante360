// auth.js - Gestion de l'authentification

// Fonction de vérification d'authentification
function checkAuth() {
    const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
    if (!isLoggedIn && !window.location.pathname.includes('index.html')) {
        window.location.href = 'index.html';
    }
}

// Fonction de login
async function login(email, password, remember) {
    try {
        if (!email || !password) {
            throw new Error("L'email et le mot de passe sont requis");
        }

        // Simulation de délai réseau
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Enregistrement de la connexion
        localStorage.setItem('isLoggedIn', 'true');
        if (remember) {
            localStorage.setItem('rememberMe', 'true');
            localStorage.setItem('userEmail', email);
        } else {
            sessionStorage.setItem('userEmail', email);
        }
        
        // Redirection vers le dashboard
        window.location.href = 'dashboard.html';
        
        return { success: true };
    } catch (error) {
        console.error("Erreur de connexion:", error);
        throw error;
    }
}

// Fonction de logout
function logout() {
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('userEmail');
    sessionStorage.removeItem('userEmail');
    window.location.href = 'index.html';
}

// Initialisation au chargement de la page
document.addEventListener('DOMContentLoaded', function() {
    // Gestion du formulaire de connexion
    const loginForm = document.getElementById('loginForm');
    const connexionBtn = document.getElementById('Connexion');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const remember = document.getElementById('remember').checked;
            
            // Désactiver le bouton pendant la tentative de connexion
            if (connexionBtn) {
                connexionBtn.disabled = true;
                connexionBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Connexion...';
            }
            
            try {
                await login(email, password, remember);
            } catch (error) {
                alert(error.message || "Erreur lors de la connexion");
                if (connexionBtn) {
                    connexionBtn.disabled = false;
                    connexionBtn.textContent = 'Connexion';
                }
            }
        });

        // Pré-remplir l'email si "Se souvenir de moi" était coché
        if (localStorage.getItem('rememberMe') === 'true') {
            const savedEmail = localStorage.getItem('userEmail') || sessionStorage.getItem('userEmail');
            if (savedEmail && document.getElementById('email')) {
                document.getElementById('email').value = savedEmail;
                document.getElementById('remember').checked = true;
            }
        }
    }

    // Gestion de la déconnexion
    document.querySelectorAll('.logout-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
    });

    // Vérification de l'authentification pour les autres pages
    if (!window.location.pathname.includes('index.html')) {
        checkAuth();
    }
});