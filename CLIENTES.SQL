USE [LOPEZ]
GO

/****** Object:  Table [dbo].[VENDEDORES]    Script Date: 21/06/2024 3:42:41 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VENDEDORES](
	[EMPRESA_CODIGO] [varchar](18) NOT NULL,
	[VENDEDOR_CODIGO] [varchar](18) NOT NULL,
	[VENDEDOR_NOMBRE] [varchar](50) NOT NULL,
	[VENDEDOR_TIPO] [varchar](30) NOT NULL,
	[VENDEDOR_TELEFONO] [nvarchar](20) NULL,
	[VENDEDOR_EMAIL] [varchar](50) NULL,
	[VENDEDOR_DIRECCION] [varchar](300) NOT NULL,
	[VENDEDOR_CIUDAD] [varchar](50) NULL,
	[VENDEDOR_PAIS] [varchar](50) NULL,
	[VENDEDOR_REGION] [varchar](50) NULL,
	[VENDEDOR_ESTADO] [char](1) NOT NULL,
	[UBICACION] [varchar](20) NULL,
	[PROCESO] [varchar](1) NOT NULL,
	[FECHA_CREA] [datetime] NOT NULL,
	[FECHA_MODIFICA] [datetime] NULL,
	[CENTRO_OPERACION] [varchar](10) NULL,
	[CEDULA] [varchar](18) NULL,
	[f2181_id_caja] [varchar](20) NULL,
	[f2181_id_cargue_fact] [varchar](20) NULL,
	[f2181_id_tipo_docto_fact] [varchar](20) NULL,
	[f2181_id_ubicacion_fact] [varchar](20) NULL,
	[f150_id] [varchar](20) NULL,
	[f2181_id_tipo_docto_pedido] [varchar](20) NULL,
	[f2181_id_co_movto_fact] [varchar](20) NULL,
	[f2181_id_co] [varchar](20) NULL,
	[f2181_ind_factura] [int] NULL,
	[f2181_id_tipo_docto_recibo] [varchar](20) NULL,
 CONSTRAINT [PK_VENDEDORES] PRIMARY KEY CLUSTERED 
(
	[EMPRESA_CODIGO] ASC,
	[VENDEDOR_CODIGO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
