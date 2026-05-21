import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface AdminOrder {
  id_pedido: number;
  fecha_pedido: string;
  total: number;
  estado: string;
  estado_id: number;
  cliente: {
    nombre: string;
    correo: string;
    telefono: string;
  };
  direccion_envio: string;
  telefono_contacto: string;
  cantidad_productos: number;
}

export interface AdminOrdersResponse {
  pedidos: AdminOrder[];
  total: number;
}
export interface OrderStatus {
  id_estado: number;
  nombre: string;
  descripcion?: string;
}
@Injectable({
  providedIn: 'root'
})
export class AdminOrdersService {
  private readonly apiUrl = `${environment.apiBaseUrl}/payment/admin`;


  constructor(private readonly http: HttpClient) {}

  getOrders(): Observable<AdminOrdersResponse> {
    return this.http.get<AdminOrdersResponse>(`${this.apiUrl}/pedidos`);
  }
  getStatuses(): Observable<OrderStatus[]> {
  return this.http.get<OrderStatus[]>(`${this.apiUrl}/estados`);
}

updateOrderStatus(orderId: number, statusId: number): Observable<any> {
  return this.http.put(
    `${this.apiUrl}/pedidos/${orderId}/estado`,
    { id_estado: statusId }
  );
}
}