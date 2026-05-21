import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormGroup, FormControl, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './register.component.html',
  styleUrl: './register.component.css'
})
// ... (imports iguales al de arriba)
export class RegisterComponent {
  registerForm = new FormGroup({
    nombreCompleto: new FormControl('', [Validators.required]),
    correo: new FormControl('', [Validators.required, Validators.email]),
    telefono: new FormControl('', [Validators.required]),
    password: new FormControl('', [Validators.required, Validators.minLength(6)]),
    confirmPassword: new FormControl('', [Validators.required])
  });

  constructor(private router: Router) {}

  onRegister() {
  console.log("Estado del formulario:", this.registerForm.value); // <--- MIRA ESTO EN LA CONSOLA (F12)
  if (this.registerForm.valid) {
    this.router.navigate(['/tienda']);
  } else {
    alert("Error: Revisa que el correo sea válido y la contraseña tenga 6+ caracteres.");
  }
}
}
