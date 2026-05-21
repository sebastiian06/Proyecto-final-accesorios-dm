import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

interface LoginRequest {
  correo: string;
  password: string;
}

interface LoginResponse {
  access_token: string;
  token_type: string;
  user_id: number;
  nombre: string;
  correo: string;
  rol: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private readonly apiUrl =
    `${environment.apiBaseUrl}/security/auth/login`;

  constructor(private http: HttpClient) {}

  login(data: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(
      this.apiUrl,
      data
    );
  }

  saveSession(response: LoginResponse): void {
    localStorage.setItem(
      'access_token',
      response.access_token
    );

    localStorage.setItem(
      'admin_user',
      JSON.stringify(response)
    );
  }

  logout(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('admin_user');
  }

  isAuthenticated(): boolean {
    return !!localStorage.getItem('access_token');
  }

 hasAdminAccess(): boolean {
  const user = localStorage.getItem('admin_user');
  if (!user) return false;

  const role = String(JSON.parse(user).rol ?? '').trim().toUpperCase();

  return ['ADMIN', 'VENDEDOR', 'ASESOR DE VENTAS', 'BODEGUERO'].includes(role);
}

isAdmin(): boolean {
  const user = localStorage.getItem('admin_user');
  if (!user) return false;

  const role = String(JSON.parse(user).rol ?? '').trim().toUpperCase();

  return role === 'ADMIN';
}  
}
