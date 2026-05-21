import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AdminClient, AdminClientsService } from '../../services/admin-clients.service';
import { Product } from '../../models/product.model';
import { Category, Material, ProductService } from '../../services/product.service';
import { AdminOrder, AdminOrdersService, OrderStatus } from '../../services/admin-orders.service';
import { AdminEmployee, AdminUsersService } from '../../services/admin-users.service';
import { AdminRole, AdminRolesService } from '../../services/admin-roles.service';
import { AdminPromotionsService, Promotion } from '../../services/admin-promotions.service';

@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.component.html',
  styleUrl: './admin.component.css'
})
export class AdminComponent implements OnInit {
  products: Product[] = [];
  categories: Category[] = [];
  materials: Material[] = [];
  orders: AdminOrder[] = [];
  orderStatuses: OrderStatus[] = [];
  employees: AdminEmployee[] = [];
  roles: AdminRole[] = [];
  promotions: Promotion[] = [];

  activeSection = 'productos';

  editingProductId: string | null = null;
  editingEmployeeId: number | null = null;
  editingRoleId: number | null = null;
  editingPromotionId: number | null = null;

  isLoading = false;
  isLoadingOrders = false;
  isUpdatingOrder = false;

  successMessage = '';
  errorMessage = '';
  ordersMessage = '';
  usersMessage = '';
  rolesMessage = '';
  promotionsMessage = '';

  selectedImageFile: File | null = null;
  previewImage = '';

  newProduct = {
    nombre: '',
    descripcion: '',
    precio: 0,
    stock: 0,
    idCategoria: 0,
    idMaterial: 0
  };

  employeeForm = {
    nombre: '',
    correo: '',
    password: '',
    id_rol: 0,
    estado: true
  };

  roleForm = {
    nombre: '',
    descripcion: ''
  };

  promotionForm = {
    nombre: '',
    descripcion: '',
    porcentajeDescuento: 0,
    fechaInicio: '',
    fechaFin: '',
    estado: true
  };

  promotionAssignment = {
    idPromocion: 0,
    idProducto: 0
  };
      clients: AdminClient[] = [];
    editingClientId: number | null = null;
    clientsMessage = '';

    clientForm = {
      nombre: '',
      correo: '',
      telefono: '',
      estado: true
    };

  constructor(
    private readonly productService: ProductService,
    private readonly adminOrdersService: AdminOrdersService,
    private readonly adminUsersService: AdminUsersService,
    private readonly adminRolesService: AdminRolesService,
    private readonly adminPromotionsService: AdminPromotionsService,
    private readonly adminClientsService: AdminClientsService
  ) {}

  get currentUserRole(): string {
    const user = localStorage.getItem('admin_user');
    if (!user) return '';
    return String(JSON.parse(user).rol ?? '').trim().toUpperCase();
  }

  get isAdminUser(): boolean {
    return this.currentUserRole === 'ADMIN';
  }

  get canManageProducts(): boolean {
    return ['ADMIN', 'VENDEDOR', 'ASESOR DE VENTAS'].includes(this.currentUserRole);
  }

  get canManageOrders(): boolean {
    return ['ADMIN', 'VENDEDOR', 'ASESOR DE VENTAS', 'BODEGUERO'].includes(this.currentUserRole);
  }

  ngOnInit(): void {
    this.loadProducts();
    this.loadCategories();
    this.loadMaterials();
    this.loadOrders();
    this.loadOrderStatuses();
    this.loadEmployees();
    this.loadRoles();
    this.loadPromotions();
    this.loadClients();
  }

  setActiveSection(section: string): void {
    this.activeSection = section;
  }

  logout(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('admin_user');
    window.location.href = '/admin/login';
  }

  loadPromotions(): void {
    this.adminPromotionsService.getPromotions().subscribe({
      next: (promotions) => {
        this.promotions = promotions;
      },
      error: () => {
        this.promotionsMessage = 'No fue posible cargar promociones.';
      }
    });
  }

  savePromotion(): void {
    this.promotionsMessage = '';

    if (
      !this.promotionForm.nombre.trim() ||
      Number(this.promotionForm.porcentajeDescuento) <= 0 ||
      !this.promotionForm.fechaInicio ||
      !this.promotionForm.fechaFin
    ) {
      this.promotionsMessage = 'Completa los campos obligatorios.';
      return;

    }
    

    const promotion = {
      nombre: this.promotionForm.nombre,
      descripcion: this.promotionForm.descripcion,
      porcentajeDescuento: Number(this.promotionForm.porcentajeDescuento),
      fechaInicio: `${this.promotionForm.fechaInicio}:00`,
      fechaFin: `${this.promotionForm.fechaFin}:00`,
      activo: this.promotionForm.estado
    };

    if (this.editingPromotionId) {
      this.adminPromotionsService.updatePromotion(this.editingPromotionId, promotion).subscribe({
        next: () => {
          this.promotionsMessage = 'Promoción actualizada correctamente.';
          this.resetPromotionForm();
          this.loadPromotions();
        },
        error: () => {
          this.promotionsMessage = 'No fue posible actualizar promoción.';
        }
      });
      return;
    }

    this.adminPromotionsService.createPromotion(promotion).subscribe({
      next: () => {
        this.promotionsMessage = 'Promoción creada correctamente.';
        this.resetPromotionForm();
        this.loadPromotions();
      },
      error: () => {
        this.promotionsMessage = 'No fue posible crear promoción.';
      }
    });
  }

  editPromotion(promotion: Promotion): void {
    this.editingPromotionId = promotion.idPromocion;

    this.promotionForm = {
      nombre: promotion.nombre,
      descripcion: promotion.descripcion,
      porcentajeDescuento: promotion.porcentajeDescuento,
      fechaInicio: promotion.fechaInicio?.slice(0, 16),
      fechaFin: promotion.fechaFin?.slice(0, 16),
      estado: promotion.activo
    };
  }

  deletePromotion(promotion: Promotion): void {
    if (!confirm(`¿Eliminar promoción "${promotion.nombre}"?`)) return;

    this.adminPromotionsService.deletePromotion(promotion.idPromocion).subscribe({
      next: () => {
        this.promotionsMessage = 'Promoción eliminada correctamente.';
        this.loadPromotions();
      },
      error: () => {
        this.promotionsMessage = 'No fue posible eliminar promoción.';
      }
    });
  }

  assignPromotionToProduct(): void {
    if (!this.promotionAssignment.idPromocion || !this.promotionAssignment.idProducto) {
      this.promotionsMessage = 'Selecciona promoción y producto.';
      return;
    }

    this.adminPromotionsService
      .assignPromotionToProduct(
        Number(this.promotionAssignment.idPromocion),
        Number(this.promotionAssignment.idProducto)
      )
      .subscribe({
        next: () => {
          this.promotionsMessage = 'Promoción asignada correctamente.';
          this.loadProducts();
        },
        error: () => {
          this.promotionsMessage = 'No fue posible asignar promoción.';
        }
      });
  }

  resetPromotionForm(): void {
    this.editingPromotionId = null;
    this.promotionForm = {
      nombre: '',
      descripcion: '',
      porcentajeDescuento: 0,
      fechaInicio: '',
      fechaFin: '',
      estado: true
    };
  }

  loadProducts(): void {
    this.isLoading = true;

    this.productService.getProducts().subscribe({
      next: (products) => {
        this.products = products;
        this.isLoading = false;

        this.products.forEach((product, index) => {
          this.productService.getProductById(product.id).subscribe({
            next: (detail) => {
              if (!detail) return;

              this.products[index] = {
                ...this.products[index],
                stock: detail.stock,
                material: detail.material,
                category: detail.category,
                description: detail.description
              };
            }
          });
        });
      },
      error: () => {
        this.errorMessage = 'No fue posible cargar los productos.';
        this.isLoading = false;
      }
    });
  }

  loadCategories(): void {
    this.productService.getCategories().subscribe({
      next: (categories) => {
        this.categories = categories;
      }
    });
  }

  loadMaterials(): void {
    this.productService.getMaterials().subscribe({
      next: (materials) => {
        this.materials = materials;
      }
    });
  }

  loadOrders(): void {
    this.isLoadingOrders = true;

    this.adminOrdersService.getOrders().subscribe({
      next: (response) => {
        this.orders = response.pedidos;
        this.isLoadingOrders = false;
      },
      error: () => {
        this.isLoadingOrders = false;
      }
    });
  }

  loadOrderStatuses(): void {
    this.adminOrdersService.getStatuses().subscribe({
      next: (statuses) => {
        this.orderStatuses = statuses;
      }
    });
  }

  updateOrderStatus(orderId: number, statusId: string): void {
    if (!statusId) return;

    this.ordersMessage = '';
    this.isUpdatingOrder = true;

    this.adminOrdersService.updateOrderStatus(orderId, Number(statusId)).subscribe({
      next: () => {
        this.ordersMessage = 'Estado actualizado correctamente.';
        this.isUpdatingOrder = false;
        this.loadOrders();
      },
      error: () => {
        this.ordersMessage = 'No fue posible actualizar el estado.';
        this.isUpdatingOrder = false;
      }
    });
  }

  loadEmployees(): void {
    this.adminUsersService.getEmployees().subscribe({
      next: (employees) => {
        this.employees = employees;
      },
      error: () => {
        this.usersMessage = 'No fue posible cargar empleados.';
      }
    });
  }

  saveEmployee(): void {
    this.usersMessage = '';

    if (!this.employeeForm.nombre.trim() || !this.employeeForm.correo.trim() || Number(this.employeeForm.id_rol) <= 0) {
      this.usersMessage = 'Completa nombre, correo y rol.';
      return;
    }

    if (!this.editingEmployeeId && !this.employeeForm.password.trim()) {
      this.usersMessage = 'La contraseña es obligatoria para crear empleado.';
      return;
    }

    const employee = {
      nombre: this.employeeForm.nombre,
      correo: this.employeeForm.correo,
      id_rol: Number(this.employeeForm.id_rol),
      estado: this.employeeForm.estado,
      ...(this.employeeForm.password.trim() ? { password: this.employeeForm.password } : {})
    };

    if (this.editingEmployeeId) {
      this.adminUsersService.updateEmployee(this.editingEmployeeId, employee).subscribe({
        next: () => {
          this.usersMessage = 'Empleado actualizado correctamente.';
          this.resetEmployeeForm();
          this.loadEmployees();
        },
        error: () => {
          this.usersMessage = 'No fue posible actualizar el empleado.';
        }
      });
      return;
    }

    this.adminUsersService.createEmployee(employee).subscribe({
      next: () => {
        this.usersMessage = 'Empleado creado correctamente.';
        this.resetEmployeeForm();
        this.loadEmployees();
      },
      error: () => {
        this.usersMessage = 'No fue posible crear el empleado.';
      }
    });
  }

  editEmployee(employee: AdminEmployee): void {
    this.editingEmployeeId = employee.id_empleado;
    this.employeeForm = {
      nombre: employee.nombre,
      correo: employee.correo,
      password: '',
      id_rol: employee.id_rol,
      estado: employee.estado
    };
  }

  toggleEmployeeStatus(employee: AdminEmployee): void {
    this.adminUsersService.toggleEmployeeStatus(employee.id_empleado).subscribe({
      next: () => {
        this.usersMessage = 'Estado del empleado actualizado.';
        this.loadEmployees();
      }
    });
  }

  deleteEmployee(employee: AdminEmployee): void {
    if (!confirm(`¿Eliminar empleado "${employee.nombre}"?`)) return;

    this.adminUsersService.deleteEmployee(employee.id_empleado).subscribe({
      next: () => {
        this.usersMessage = 'Empleado eliminado correctamente.';
        this.loadEmployees();
      }
    });
  }

  resetEmployeeForm(): void {
    this.editingEmployeeId = null;
    this.employeeForm = {
      nombre: '',
      correo: '',
      password: '',
      id_rol: 0,
      estado: true
    };
  }

  loadRoles(): void {
    this.adminRolesService.getRoles().subscribe({
      next: (roles) => {
        this.roles = roles;
      },
      error: () => {
        this.rolesMessage = 'No fue posible cargar roles.';
      }
    });
  }

  saveRole(): void {
    this.rolesMessage = '';

    if (!this.roleForm.nombre.trim()) {
      this.rolesMessage = 'El nombre del rol es obligatorio.';
      return;
    }

    const role = {
      nombre: this.roleForm.nombre,
      descripcion: this.roleForm.descripcion
    };

    if (this.editingRoleId) {
      this.adminRolesService.updateRole(this.editingRoleId, role).subscribe({
        next: () => {
          this.rolesMessage = 'Rol actualizado correctamente.';
          this.resetRoleForm();
          this.loadRoles();
        }
      });
      return;
    }

    this.adminRolesService.createRole(role).subscribe({
      next: () => {
        this.rolesMessage = 'Rol creado correctamente.';
        this.resetRoleForm();
        this.loadRoles();
      },
      error: () => {
        this.rolesMessage = 'No fue posible crear el rol.';
      }
    });
  }

  editRole(role: AdminRole): void {
    this.editingRoleId = role.id_rol;
    this.roleForm = {
      nombre: role.nombre,
      descripcion: role.descripcion ?? ''
    };
  }

  deleteRole(role: AdminRole): void {
    if (!confirm(`¿Eliminar rol "${role.nombre}"?`)) return;

    this.adminRolesService.deleteRole(role.id_rol).subscribe({
      next: () => {
        this.rolesMessage = 'Rol eliminado correctamente.';
        this.loadRoles();
      }
    });
  }

  resetRoleForm(): void {
    this.editingRoleId = null;
    this.roleForm = {
      nombre: '',
      descripcion: ''
    };
  }

  onImageSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (!input.files?.length) return;

    this.selectedImageFile = input.files[0];

    const reader = new FileReader();
    reader.onload = () => {
      this.previewImage = reader.result as string;
    };
    reader.readAsDataURL(this.selectedImageFile);
  }

  saveProduct(): void {
    this.clearMessages();

    if (!this.isFormValid()) {
      this.errorMessage = 'Completa todos los campos obligatorios.';
      return;
    }

    const product = this.buildProductRequest();

    if (this.editingProductId) {
      this.productService.updateProduct(this.editingProductId, product).subscribe({
        next: () => {
          if (this.selectedImageFile) {
            this.uploadImageAndFinish(this.editingProductId!, 'Producto actualizado correctamente.');
            return;
          }

          this.successMessage = 'Producto actualizado correctamente.';
          this.resetForm();
          this.loadProducts();
        }
      });
      return;
    }

    this.productService.createProduct(product).subscribe({
      next: (response: any) => {
        const productId = String(response.idProducto ?? response.id ?? '');

        if (this.selectedImageFile && productId) {
          this.uploadImageAndFinish(productId, 'Producto creado correctamente.');
          return;
        }

        this.successMessage = 'Producto creado correctamente.';
        this.resetForm();
        this.loadProducts();
      }
    });
  }

  editProduct(product: Product): void {
    this.clearMessages();

    this.productService.getProductById(product.id).subscribe({
      next: (detail: Product | null) => {
        if (!detail) return;

        this.editingProductId = detail.id;
        this.newProduct = {
          nombre: detail.name,
          descripcion: detail.description,
          precio: Number(detail.price),
          stock: Number(detail.stock),
          idCategoria: this.getCategoryIdByName(detail.category),
          idMaterial: this.getMaterialIdByName(detail.material)
        };

        this.previewImage = detail.imageUrl;
        this.selectedImageFile = null;
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    });
  }

  deleteProduct(product: Product): void {
    if (!confirm(`¿Eliminar el producto "${product.name}"?`)) return;

    this.productService.deleteProduct(product.id).subscribe({
      next: () => {
        this.successMessage = 'Producto eliminado correctamente.';
        this.loadProducts();
      }
    });
  }

  cancelEdit(): void {
    this.resetForm();
    this.clearMessages();
  }
  loadClients(): void {
  this.adminClientsService.getClients().subscribe({
    next: (clients) => {
      this.clients = clients;
    },
    error: () => {
      this.clientsMessage = 'No fue posible cargar clientes.';
    }
  });
}

editClient(client: AdminClient): void {
  this.editingClientId = client.id_cliente;

  this.clientForm = {
    nombre: client.nombre,
    correo: client.correo,
    telefono: client.telefono ?? '',
    estado: client.estado ?? true
  };
}

saveClient(): void {
  if (!this.editingClientId) return;

  this.adminClientsService.updateClient(this.editingClientId, this.clientForm).subscribe({
    next: () => {
      this.clientsMessage = 'Cliente actualizado correctamente.';
      this.resetClientForm();
      this.loadClients();
    },
    error: () => {
      this.clientsMessage = 'No fue posible actualizar cliente.';
    }
  });
}

deleteClient(client: AdminClient): void {
  if (!confirm(`¿Eliminar cliente "${client.nombre}"?`)) return;

  this.adminClientsService.deleteClient(client.id_cliente).subscribe({
    next: () => {
      this.clientsMessage = 'Cliente eliminado correctamente.';
      this.loadClients();
    },
    error: () => {
      this.clientsMessage = 'No fue posible eliminar cliente.';
    }
  });
}

resetClientForm(): void {
  this.editingClientId = null;

  this.clientForm = {
    nombre: '',
    correo: '',
    telefono: '',
    estado: true
  };
}

  private buildProductRequest() {
    return {
      nombre: this.newProduct.nombre,
      descripcion: this.newProduct.descripcion,
      precio: Number(this.newProduct.precio),
      stock: Number(this.newProduct.stock),
      categoria: { idCategoria: Number(this.newProduct.idCategoria) },
      material: { idMaterial: Number(this.newProduct.idMaterial) },
      estado: true
    };
  }

  private uploadImageAndFinish(productId: string, message: string): void {
    if (!this.selectedImageFile) return;

    this.productService.uploadProductImage(productId, this.selectedImageFile).subscribe({
      next: () => {
        this.successMessage = message;
        this.resetForm();
        this.loadProducts();
      }
    });
  }

  private getCategoryIdByName(categoryName?: string): number {
    return this.categories.find((item) => item.nombre === categoryName)?.idCategoria ?? 0;
  }

  private getMaterialIdByName(materialName?: string): number {
    return this.materials.find((item) => item.nombre === materialName)?.idMaterial ?? 0;
  }

  private isFormValid(): boolean {
    return (
      !!this.newProduct.nombre.trim() &&
      !!this.newProduct.descripcion.trim() &&
      Number(this.newProduct.precio) > 0 &&
      Number(this.newProduct.stock) > 0 &&
      Number(this.newProduct.idCategoria) > 0 &&
      Number(this.newProduct.idMaterial) > 0
    );
  }

  private resetForm(): void {
    this.editingProductId = null;
    this.selectedImageFile = null;
    this.previewImage = '';

    this.newProduct = {
      nombre: '',
      descripcion: '',
      precio: 0,
      stock: 0,
      idCategoria: 0,
      idMaterial: 0
    };
  }

  private clearMessages(): void {
    this.successMessage = '';
    this.errorMessage = '';
  }
}