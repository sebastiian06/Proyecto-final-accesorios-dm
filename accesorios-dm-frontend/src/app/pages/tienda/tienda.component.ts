import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CartService } from '../../services/cart.service';
import { ProductService } from '../../services/product.service';
import { Product } from '../../models/product.model';

@Component({
  selector: 'app-tienda',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './tienda.component.html',
  styleUrl: './tienda.component.css'
})
export class TiendaComponent implements OnInit {

  productos: Product[] = [];
  productosFiltrados: Product[] = []; // 🔥 NUEVO
  totalItems: number = 0;

  constructor(
    private cartService: CartService,
    private productService: ProductService
  ) {}

  ngOnInit(): void {

    // 🔥 Traer productos
    this.productService.getProducts().subscribe(data => {
      this.productos = data;
      this.productosFiltrados = data; // 🔥 mostrar todos al inicio
    });

    // 🔥 Contador carrito
    this.cartService.cart$.subscribe(productos => {
      this.totalItems = productos.reduce((acc, item) => acc + item.cantidad, 0);
    });
  }

  // 🔥 FILTRAR POR CATEGORÍA
  filtrarPorCategoria(categoria: string) {
    this.productosFiltrados = this.productos.filter(producto =>
      producto.category?.toLowerCase() === categoria.toLowerCase()
    );
  }

  // 🔥 MOSTRAR TODOS
  mostrarTodos() {
    this.productosFiltrados = this.productos;
  }

  // 🔥 AGREGAR AL CARRITO
  agregarAlCarrito(product: Product) {
    this.cartService.addToCart(product);
  }
}
