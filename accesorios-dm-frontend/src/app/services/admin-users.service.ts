import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface AdminEmployee {
  id_empleado: number;
  nombre: string;
  correo: string;
  id_rol: number;
  estado: boolean;
  fecha_creacion: string;
  rol_nombre?: string;
}

export interface EmployeeRequest {
  nombre: string;
  correo: string;
  password?: string;
  id_rol: number;
  estado: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class AdminUsersService {
  private readonly apiUrl = `${environment.apiBaseUrl}/security/empleados/`;

  constructor(private readonly http: HttpClient) {}

  getEmployees(): Observable<AdminEmployee[]> {
    return this.http.get<AdminEmployee[]>(this.apiUrl, {
      headers: this.getHeaders()
    });
  }

  createEmployee(employee: EmployeeRequest): Observable<AdminEmployee> {
    return this.http.post<AdminEmployee>(this.apiUrl, employee, {
      headers: this.getHeaders()
    });
  }

  updateEmployee(id: number, employee: Partial<EmployeeRequest>): Observable<AdminEmployee> {
    return this.http.put<AdminEmployee>(`${this.apiUrl}${id}`, employee, {
      headers: this.getHeaders()
    });
  }

  deleteEmployee(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}${id}`, {
      headers: this.getHeaders()
    });
  }

  toggleEmployeeStatus(id: number): Observable<any> {
    return this.http.patch(`${this.apiUrl}${id}/toggle-estado`, {}, {
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