import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface AdminClient {
  id_cliente: number;
  nombre: string;
  correo: string;
  telefono?: string;
  estado?: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class AdminClientsService {
  private readonly apiUrl = `${environment.apiBaseUrl}/security/clientes/`;

  constructor(private readonly http: HttpClient) {}

  getClients(): Observable<AdminClient[]> {
    return this.http.get<AdminClient[]>(this.apiUrl, {
      headers: this.getHeaders()
    });
  }

  updateClient(id: number, client: Partial<AdminClient>): Observable<AdminClient> {
    return this.http.put<AdminClient>(`${this.apiUrl}${id}`, client, {
      headers: this.getHeaders()
    });
  }

  deleteClient(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}${id}`, {
      headers: this.getHeaders()
    });
  }

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token') ?? '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }
}