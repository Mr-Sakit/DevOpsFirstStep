import { FormEvent, useEffect, useMemo, useState } from "react";
import {
  BadgeCheck,
  BrainCircuit,
  FileSignature,
  FileText,
  LockKeyhole,
  LogOut,
  Send,
  Search,
  ShieldCheck,
  UploadCloud
} from "lucide-react";
import {
  AuthSession,
  DocumentRecord,
  getSession,
  listDocuments,
  login,
  logout,
  uploadDocument
} from "./services/api";
import { trackHandledError } from "./telemetry";

const capabilities = [
  { icon: FileSignature, label: "Signature Routing", value: "Send contracts, approvals, and attestations to verified corporate signers." },
  { icon: Search, label: "Matter Search", value: "Find active envelopes by signer, owner, file name, or business category." },
  { icon: BrainCircuit, label: "Document Intelligence", value: "Extract parties, obligations, payment terms, dates, and exception language." },
  { icon: ShieldCheck, label: "Evidence Controls", value: "Retain signer identity, timestamps, file metadata, and workflow state." },
  { icon: LockKeyhole, label: "Least Privilege", value: "Users see only envelopes they own or have been asked to sign." }
];

export function App() {
  const [session, setSession] = useState<AuthSession | null>(null);
  const [documents, setDocuments] = useState<DocumentRecord[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isCheckingSession, setIsCheckingSession] = useState(true);
  const [email, setEmail] = useState("automission@company.com");
  const [password, setPassword] = useState("auto");
  const [isUploadOpen, setIsUploadOpen] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [category, setCategory] = useState("Contract");
  const [signerEmail, setSignerEmail] = useState("legal.approver@company.com");
  const [deadline, setDeadline] = useState("Due this week");
  const currentEmail = session?.email ?? "";

  useEffect(() => {
    getSession()
      .then((currentSession) => {
        setSession(currentSession);
        if (currentSession) {
          return listDocuments().then(setDocuments);
        }
        return undefined;
      })
      .catch(() => setSession(null))
      .finally(() => setIsCheckingSession(false));
  }, []);

  const metrics = useMemo(
    () => [
      { label: "Signature Inbox", value: documents.filter((doc) => doc.signerEmail === currentEmail && !doc.signatureStatus.includes("Signed")).length.toString() },
      { label: "Sent for Signature", value: documents.filter((doc) => doc.ownerUsername === currentEmail && doc.signerEmail !== currentEmail).length.toString() },
      { label: "Completed", value: documents.filter((doc) => doc.signatureStatus.includes("Signed")).length.toString() }
    ],
    [documents, currentEmail]
  );

  const signatureInbox = documents.filter((doc) => doc.signerEmail === currentEmail);
  const sentForSignature = documents.filter((doc) => doc.ownerUsername === currentEmail);

  async function handleAuthSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setAuthError(null);
    try {
      const nextSession = await login(email, password);
      setSession(nextSession);
      setDocuments(await listDocuments());
    } catch (err) {
      trackHandledError(err, "login");
      setAuthError(err instanceof Error ? err.message : "Authentication failed");
    }
  }

  async function handleUploadSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!session || !selectedFile) {
      setError("Choose a document before uploading.");
      return;
    }
    setIsSaving(true);
    setError(null);
    try {
      const created = await uploadDocument(selectedFile, category, signerEmail, deadline, session.csrfToken);
      setDocuments((current) => [created, ...current]);
      setSelectedFile(null);
      setIsUploadOpen(false);
    } catch (err) {
      trackHandledError(err, "upload-document");
      setError(err instanceof Error ? err.message : "Unable to upload document");
    } finally {
      setIsSaving(false);
    }
  }

  async function handleLogout() {
    if (session) {
      await logout(session.csrfToken).catch(() => undefined);
    }
    setSession(null);
    setDocuments([]);
  }

  if (isCheckingSession) {
    return <main className="auth-shell" />;
  }

  if (!session) {
    return (
      <main className="auth-shell">
        <section className="auth-panel" aria-label="SecureFlow authentication">
          <div>
            <p className="eyebrow">Secure access</p>
            <h1>SecureFlow Docs</h1>
            <p>Access signing queues, prepared envelopes, and governed document records with your corporate identity.</p>
          </div>
          <form className="auth-form" onSubmit={handleAuthSubmit}>
            <label>
              Corporate email
              <input type="email" value={email} onChange={(event) => setEmail(event.target.value)} maxLength={120} required />
            </label>
            <label>
              Password
              <input type="password" value={password} onChange={(event) => setPassword(event.target.value)} minLength={4} maxLength={72} required />
            </label>
            {authError ? <p className="error">{authError}</p> : null}
            <button type="submit">
              <LockKeyhole size={18} aria-hidden="true" />
              Continue securely
            </button>
          </form>
        </section>
      </main>
    );
  }

  return (
    <main>
      <section className="hero">
        <div className="hero__content">
          <p className="eyebrow">Enterprise signature operations</p>
          <h1>SecureFlow Docs</h1>
          <p className="hero__copy">
            Govern high-value agreements from intake to signature with private document ownership,
            signer-specific work queues, evidence retention, and AI-ready metadata for legal,
            finance, procurement, and HR teams.
          </p>
          <div className="hero__actions">
            <button onClick={() => setIsUploadOpen(true)} disabled={isSaving}>
              <UploadCloud size={18} aria-hidden="true" />
              Prepare envelope
            </button>
            <button className="ghost-button" onClick={handleLogout}>
              <LogOut size={18} aria-hidden="true" />
              Logout {session.email}
            </button>
            <span className="gateway-pill">
              <ShieldCheck size={18} aria-hidden="true" />
              Private access and signer-scoped records
            </span>
          </div>
        </div>
        <div className="document-panel" aria-label="SecureFlow workflow status">
          <div className="panel-header">
            <FileText aria-hidden="true" />
            <span>Signature Control Center</span>
          </div>
          {metrics.map((metric) => (
            <div className="metric" key={metric.label}>
              <strong>{metric.value}</strong>
              <span>{metric.label}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="capabilities" aria-label="Platform capabilities">
        {capabilities.map(({ icon: Icon, label, value }) => (
          <article key={label}>
            <Icon aria-hidden="true" />
            <h2>{label}</h2>
            <p>{value}</p>
          </article>
        ))}
      </section>

      <section className="documents">
        <div>
          <p className="eyebrow">Signer workspace</p>
          <h2>Documents Awaiting My Signature</h2>
        </div>
        {error ? <p className="error">{error}</p> : null}
        <div className="table" role="table" aria-label="Documents">
          <div className="table-row table-head" role="row">
            <span>Title</span>
            <span>Category</span>
            <span>Signature status</span>
            <span>Requested by</span>
          </div>
          {signatureInbox.map((doc) => (
            <div className="table-row" role="row" key={doc.id}>
              <span>
                <BadgeCheck size={16} aria-hidden="true" />
                {doc.title}
              </span>
              <span>{doc.category}</span>
              <span>{doc.signatureStatus}</span>
              <span>{doc.ownerUsername}</span>
            </div>
          ))}
          {signatureInbox.length === 0 ? <p className="empty">No signature requests are currently assigned to {session.email}.</p> : null}
        </div>
      </section>

      <section className="documents documents--sent">
        <div>
          <p className="eyebrow">Owner workspace</p>
          <h2>Documents I Sent for Signature</h2>
        </div>
        <div className="table" role="table" aria-label="Sent documents">
          <div className="table-row table-head" role="row">
            <span>Title</span>
            <span>Signer</span>
            <span>Deadline</span>
            <span>Status</span>
          </div>
          {sentForSignature.map((doc) => (
            <div className="table-row" role="row" key={`sent-${doc.id}`}>
              <span>
                <Send size={16} aria-hidden="true" />
                {doc.title}
              </span>
              <span>{doc.signerEmail}</span>
              <span>{doc.signatureDeadline ?? "Standard SLA"}</span>
              <span>{doc.signatureStatus}</span>
            </div>
          ))}
          {sentForSignature.length === 0 ? <p className="empty">No outbound signature envelopes have been prepared yet.</p> : null}
        </div>
      </section>
      {isUploadOpen ? (
        <div className="modal-backdrop" role="presentation">
          <form className="upload-modal" onSubmit={handleUploadSubmit} aria-label="Upload document">
            <div>
              <p className="eyebrow">Prepare signature envelope</p>
              <h2>Upload for signing</h2>
            </div>
            <label>
              Business category
              <input value={category} onChange={(event) => setCategory(event.target.value)} maxLength={60} required />
            </label>
            <label>
              Signer corporate email
              <input type="email" value={signerEmail} onChange={(event) => setSignerEmail(event.target.value)} maxLength={120} required />
            </label>
            <label>
              Signature deadline
              <input value={deadline} onChange={(event) => setDeadline(event.target.value)} maxLength={120} required />
            </label>
            <label>
              Document
              <input type="file" onChange={(event) => setSelectedFile(event.target.files?.[0] ?? null)} required />
            </label>
            <div className="modal-actions">
              <button type="button" className="secondary-button" onClick={() => setIsUploadOpen(false)}>
                Cancel
              </button>
              <button type="submit" disabled={isSaving || !selectedFile}>
                <UploadCloud size={18} aria-hidden="true" />
                {isSaving ? "Preparing" : "Send for signature"}
              </button>
            </div>
          </form>
        </div>
      ) : null}
    </main>
  );
}
