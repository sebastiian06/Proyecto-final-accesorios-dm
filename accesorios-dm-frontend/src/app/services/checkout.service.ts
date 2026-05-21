import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';

export interface CheckoutRequest {
  cliente: {
    nombre: string;
    correo: string;
    telefono: string;
  };
  items: {
    id_producto: number;
    cantidad: number;
    precio_unitario: number;
  }[];
  direccion_envio: string;
  telefono_contacto: string;
}

@Injectable({
  providedIn: 'root'
})
export class CheckoutService {
  private readonly apiUrl = `${environment.apiBaseUrl}/payment/pedidos/checkout`;

  constructor(private readonly http: HttpClient) {}

  checkout(body: CheckoutRequest) {
    return this.http.post<any>(this.apiUrl, body);
  }
}