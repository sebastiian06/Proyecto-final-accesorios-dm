import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { CartItem, CartService } from '../../services/cart.service';
import { CheckoutService } from '../../services/checkout.service';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './cart.component.html',
  styleUrl: './cart.component.css'
})
export class CartComponent implements OnInit {
  items: CartItem[] = [];
  total = 0;
  isSubmitting = false;
  successMessage = '';
  errorMessage = '';
  showCheckout = false;

  checkoutForm = {
    nombre: '',
    correo: '',
    telefono: '',
    direccion_envio: ''
  
  };

  constructor(
    private readonly cartService: CartService,
    private readonly checkoutService: CheckoutService
  ) {}

  ngOnInit(): void {
    this.loadCart();
  }

  loadCart(): void {
    this.items = this.cartService.getItems();
    this.total = this.cartService.getTotal();
  }

  increase(productId: string): void {
    this.cartService.increaseProduct(productId);
    this.loadCart();
  }

  decrease(productId: string): void {
    this.cartService.decreaseProduct(productId);
    this.loadCart();
  }

  remove(productId: string): void {
    this.cartService.removeProduct(productId);
    this.loadCart();
  }

  finishPurchase(): void {
    this.successMessage = '';
    this.errorMessage = '';

    if (this.items.length === 0) {
      this.errorMessage = 'Tu carrito está vacío.';
      return;
    }

    const { nombre, correo, telefono, direccion_envio } = this.checkoutForm;

    if (!nombre || !correo || !telefono || !direccion_envio) {
      this.errorMessage = 'Completa todos los datos para finalizar la compra.';
      return;
    }

    const body = {
      cliente: { nombre, correo, telefono },
      items: this.items.map((item) => ({
        id_producto: Number(item.product.id),
        cantidad: item.quantity,
        precio_unitario: item.product.price
      })),
      direccion_envio,
      telefono_contacto: telefono
    };

    this.isSubmitting = true;

    this.checkoutService.checkout(body).subscribe({
      next: (response) => {
        this.isSubmitting = false;
        this.cartService.clearCart();
        this.loadCart();
        this.successMessage = 'Pedido creado exitosamente. Te llevaremos a WhatsApp.';

        if (response?.whatsapp_link) {
          window.location.href = response.whatsapp_link;
        }
      },
      error: () => {
        this.isSubmitting = false;
        this.errorMessage = 'No fue posible finalizar la compra.';
      }
    });
  }
  openCheckout(): void {
  this.showCheckout = true;

  setTimeout(() => {
    document.querySelector('.checkout-section')?.scrollIntoView({
      behavior: 'smooth',
      block: 'start'
    });
  }, 100);
}
}