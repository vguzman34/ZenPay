export interface User {
  id: string;
  email: string;
  fullName: string;
  phone: string;
  photoUrl: string;
  role: string;
  mfaEnabled: boolean;
  lastLoginAt: string;
  createdAt: string;
}

export interface UpdateProfileRequest {
  fullName: string;
  phone: string;
  photoUrl: string;
}

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}
