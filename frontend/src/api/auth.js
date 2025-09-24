const BASE = import.meta.env.DEV ? "" : "http://18.144.2.70";

async function handleResponse(response) {
    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
        return response.json();
    }
    throw new Error(`Unexpected content type: ${contentType}`);
}

export async function register({ username, email, password }) {
    const r = await fetch(`${BASE}/api/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, email, password }),
        credentials: "include"
    });

    if (!r.ok) {
        const data = await handleResponse(r);
        throw new Error(data.error);
    }
}

export async function login({ email, password }) {
    const r = await fetch(`${BASE}/api/login`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
        body: JSON.stringify({ email, password }),
        credentials: "include",
    });
    
    if (!r.ok) {
        const data = await r.json();
        throw new Error(data.error || 'Login failed');
    }
    
    const data = await r.json();
    return true;
}

export async function logout() {
    await fetch(`${BASE}/api/logout`, {
        method: "POST",
        credentials: "include",
    });
}

export async function getUser() {
    const r = await fetch(`${BASE}/api/user`, {
        credentials: "include"
    });

    if (!r.ok) throw new Error("Not logged in");
    return r.json();
}

export async function addTicker(ticker) {
    const email = (await getUser()).email;
    await fetch(`${BASE}/api/addticker`, {
        method: "POST",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, ticker }),
    });
}

export async function removeTicker(ticker) {
    const token = localStorage.getItem("token");
    const email = (await getUser()).email;
    await fetch(`${BASE}/api/removeticker`, {
        method: "DELETE",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, ticker }),
    });
}
