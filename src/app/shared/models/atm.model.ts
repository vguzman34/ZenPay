export interface Atm {
  id: string;
  name: string;
  bankName: string;
  bankLogo: string;
  address: string;
  latitude: number;
  longitude: number;
  distance: number;
  walkingTime: number;
  drivingTime: number;
  isOpen24Hours: boolean;
  openTime: string;
  closeTime: string;
  isOpen: boolean;
  services: string[];
}

export interface AtmDetail extends Atm {
  services: string[];
}
