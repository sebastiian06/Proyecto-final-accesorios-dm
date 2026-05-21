import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

import { CartDrawerComponent } from './components/cart-drawer/cart-drawer.component';
import { FooterComponent } from './components/footer/footer.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterOutlet,
    FooterComponent,
    CartDrawerComponent
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {}