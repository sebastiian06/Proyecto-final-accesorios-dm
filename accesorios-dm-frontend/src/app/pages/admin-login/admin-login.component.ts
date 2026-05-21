import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-admin-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-login.component.html',
  styleUrl: './admin-login.component.css'
})
export class AdminLoginComponent {
  correo = '';
  password = '';
  isLoading = false;
  errorMessage = '';

  constructor(
    private readonly authService: AuthService,
    private readonly router: Router
  ) {}

  login(): void {
    if (this.isLoading) return;

    this.errorMessage = '';

    if (!this.correo.trim() || !this.password.trim()) {
      this.errorMessage = 'Ingresa correo y contraseña.';
      return;
    }

    this.isLoading = true;

    this.authService.login({
      correo: this.correo.trim(),
      password: this.password.trim()
    }).subscribe({
      next: (response) => {
        this.isLoading = false;

        const role = String(response.rol ?? '').trim().toUpperCase();

        if (!['ADMIN', 'VENDEDOR', 'ASESOR DE VENTAS', 'BODEGUERO'].includes(role)) {
          this.authService.logout();
          this.errorMessage = 'No tienes permisos para ingresar al panel.';
          return;
        }

        this.authService.saveSession(response);

        this.router.navigateByUrl('/admin');
      },
      error: (error) => {
        console.error('Error login admin:', error);
        this.isLoading = false;
        this.errorMessage = 'Credenciales incorrectas o usuario inactivo.';
      }
    });
  }
}