import { Component } from '@angular/core';
import { CartService } from '../../services/cart.service';
import { ProductFactory, ProductType } from '../../factories/product.factory';

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html'
})
export class ProductListComponent {

  constructor(private cartService: CartService) {}

  addProduct(type: ProductType) {
  const product = ProductFactory.createProduct(type);
  console.log("Producto creado:", product); // 👈 DEBUG
  this.cartService.addToCart(product);
}
}
