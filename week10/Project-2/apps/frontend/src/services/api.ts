export type DocumentRecord = {
  id: number;
  title: string;
  category: string;
  status: string;
  owner: string;
  ownerUsername: string;
  signerEmail: string;
  signatureStatus: string;
  signatureDeadline?: string;
  originalFileName?: string;
  contentType?: string;
  fileSize?: number;
  extractedSummary: string;
};

export type AuthSession = {
  email: string;
  csrfToken: string;
};

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "/api";

async function readJson<T>(response: Response, fallbackMessage: string): Promise<T> {
  if (!response.ok) {
    const body = await response.json().catch(() => null);
    throw new Error(body?.error ?? fallbackMessage);
  }
  return response.json();
}

export async function getSession(): Promise<AuthSession | null> {
  const response = await fetch(`${API_BASE_URL}/auth/me`, { credentials: "include" });
  if (response.status === 401) {
    return null;
  }
  return readJson<AuthSession>(response, "Unable to load session");
}

export async function login(email: string, password: string): Promise<AuthSession> {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password })
  });
  return readJson<AuthSession>(response, "Unable to login");
}

export async function logout(csrfToken: string): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/auth/logout`, {
    method: "POST",
    credentials: "include",
    headers: { "X-CSRF-Token": csrfToken }
  });
  if (!response.ok) {
    throw new Error("Unable to logout");
  }
}

export async function listDocuments(): Promise<DocumentRecord[]> {
  const response = await fetch(`${API_BASE_URL}/documents`, { credentials: "include" });
  return readJson<DocumentRecord[]>(response, "Unable to load documents");
}

export async function uploadDocument(
  file: File,
  category: string,
  signerEmail: string,
  deadline: string,
  csrfToken: string
): Promise<DocumentRecord> {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("category", category);
  formData.append("signerEmail", signerEmail);
  formData.append("deadline", deadline);

  const response = await fetch(`${API_BASE_URL}/documents`, {
    method: "POST",
    credentials: "include",
    headers: { "X-CSRF-Token": csrfToken },
    body: formData
  });
  return readJson<DocumentRecord>(response, "Unable to upload document");
}
