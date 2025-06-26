# apollo-kivana

Infraestructura como código para desplegar una arquitectura MEAN (MongoDB, Express, Apollo Server, Node.js) en AWS usando Terraform y Packer.

---

## Requisitos previos

- [Terraform](https://www.terraform.io/downloads)
- [Packer](https://developer.hashicorp.com/packer/downloads) (descarga el binario directamente si tu gestor de paquetes lo ha deshabilitado)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Credenciales de AWS con permisos suficientes para EC2, VPC, IAM, etc.
- [Node.js](https://nodejs.org/) (opcional, solo si quieres probar los scripts localmente)

---

## Configuración inicial

1. **Clona el repositorio y entra al directorio:**
   ```sh
   git clone <repo-url>
   cd apollo-kivana
   ```

2. **Configura tus credenciales de AWS:**
   ```sh
   aws configure
   ```
   O exporta las variables de entorno:
   ```sh
   export AWS_ACCESS_KEY_ID="TU_ACCESS_KEY"
   export AWS_SECRET_ACCESS_KEY="TU_SECRET_KEY"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

3. **Inicializa Terraform:**
   ```sh
   terraform init
   ```

---

## Primer despliegue (build completo)

1. **Haz un dry run para ver qué se va a crear:**
   ```sh
   terraform plan
   ```

2. **Aplica la infraestructura (esto creará red, llaves, seguridad, AMI y servidores):**
   ```sh
   terraform apply
   ```
   Confirma con `yes` cuando se te solicite.

   - Terraform generará una llave SSH y la guardará en `modules/llave/id_rsa`.
   - Packer construirá una AMI personalizada usando esa llave.
   - Se desplegarán los servidores usando la AMI generada.

---

## Notas importantes

- Si tienes problemas con la red o la caché de paquetes en la creación de la AMI, el provisioner de Packer ya incluye limpieza y un delay para robustecer la instalación.
- El nombre de la AMI es único por build (`ami-apollo-{{timestamp}}`).
- La llave privada generada por Terraform se usa automáticamente en el build de Packer y para acceder a las instancias EC2.
- Para limpiar toda la infraestructura:
  ```sh
  terraform destroy
  ```

---

## Estructura del proyecto

- `main.tf` — Orquestador principal de Terraform.
- `modules/` — Módulos reutilizables: red, seguridad, llaves, AMI, servidores.
- `packer/` — Configuración de Packer y archivos de ejemplo para el servidor Apollo.
- `packer/files/` — Código fuente y configuración que se copia a la AMI.

---

## Troubleshooting

- Si Packer falla por permisos de la llave, asegúrate de que `modules/llave/id_rsa` existe y tiene permisos `600`.
- Si ves errores de red en la provisión de la AMI, simplemente vuelve a intentar el build; la configuración ya incluye mitigaciones comunes.

---

## Dry run

Para hacer un dry run del proyecto:
```sh
terraform plan
```
Esto mostrará todos los recursos que se crearán/modificarán sin aplicar cambios.

---

¿Dudas? Abre un issue o revisa los módulos para más detalles.

---

## Acceso a Apollo Server

Una vez desplegada la instancia EC2, puedes acceder a Apollo Server visitando la IP pública de la instancia en el puerto 4000:

```
http://<IP_PUBLICA_EC2>:4000/
```

Si todo está correcto, Apollo Server debería estar funcionando y accesible en esa dirección.
