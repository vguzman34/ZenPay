export interface Device {
  id: string;
  deviceName: string;
  deviceType: string;
  os: string;
  browser: string;
  ipAddress: string;
  location: string;
  isTrusted: boolean;
  lastUsedAt: string;
}
