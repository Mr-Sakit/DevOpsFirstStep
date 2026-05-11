import { ApplicationInsights } from "@microsoft/applicationinsights-web";

const connectionString = import.meta.env.VITE_APPLICATIONINSIGHTS_CONNECTION_STRING;

export const appInsights = connectionString
  ? new ApplicationInsights({
      config: {
        connectionString,
        enableAutoRouteTracking: true,
        enableCorsCorrelation: true
      }
    })
  : null;

export function initializeTelemetry() {
  if (!appInsights) {
    return;
  }

  appInsights.loadAppInsights();
  appInsights.trackPageView({ name: "SecureFlow Docs" });
}

export function trackHandledError(error: unknown, context: string) {
  if (!appInsights) {
    return;
  }

  const exception = error instanceof Error ? error : new Error(String(error));
  appInsights.trackException({
    exception,
    properties: { context }
  });
}
