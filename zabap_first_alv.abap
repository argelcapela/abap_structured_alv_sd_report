********************************************************************************
* Empresa         : XXXXXXXXXXXXXXX                                 	         *
* Cliente         : XXXXXXXXXXXXXXX                                 	         *
* Modulo          : XXXXXXXXXXXXXXX                                 	         *
* Titulo          : XXXXXXXXXXXXXXX                                 	         *
* Programa        : XXXXXXXXXXXXXXX                                 	         *
* Transação       : XXXXXXXXXXXXXXX                                 	         *
* Tipo Programa   : XXXXXXXXXXXXXXX                                 	         *
* Funcional       : XXXXXXXXXXXXXXX                                 	         *
* Desenvolvedor   : XXXXXXXXXXXXXXX                                 	         *
* Data Criação    : XXXXXXXXXXXXXXX                                 	         *
*------------------------------------------------------------------------------*
*                           [HISTÓRICO]                                	       *
*------------------------------------------------------------------------------*
* Ult Modif   Autor          Chamado      Descrição                            *
* XXXXXXXXXX  XXXXXXXXXXXX   XXXXXXXXXX   XXXXXXXXXXX                          *
*------------------------------------------------------------------------------*
REPORT zabap_first_alv.

*----------------------------------------------------------------------*
* TABELAS                                                              *
*----------------------------------------------------------------------*
TABLES: vbak.

*----------------------------------------------------------------------*
* TIPOS                                                                *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF y_vbak,
    vbeln TYPE vbak-vbeln,                        " Documento de vendas
    erdat TYPE vbak-erdat,                        " Data de criação do registro
    auart TYPE vbak-auart,                        " Tipo de Documento
    augru TYPE vbak-augru,                        " Motivo da Ordem - Descrição
    vkorg TYPE vbak-vkorg,                        " Organização de vendas
    bstnk TYPE vbak-bstnk,                        " Referência de Cliente
    bstdk TYPE vbak-bstdk,                        " Data de Envio
    bname TYPE vbak-bname,                        " Nome do emissor do pedido
  END OF y_vbak,

  BEGIN OF y_vbap,
    vbeln TYPE vbap-vbeln,                        " Documento de vendas
    matnr TYPE vbap-matnr,                        " Nº do material
  END OF y_vbap,

  BEGIN OF y_tvakt,
    auart TYPE tvakt-auart,                       " Tipo de documento de vendas
    bezei TYPE tvakt-bezei,                       " Descrição do tipo de documento de vendas
  END OF y_tvakt,

  BEGIN OF y_tvaut,
    augru TYPE tvaut-augru,                       " Motivo da ordem (motivo da transação comercial)
    bezei TYPE tvaut-bezei,                       " Motivo da Ordem - Descrição
  END OF y_tvaut,

  BEGIN OF y_vbpa,
    vbeln TYPE vbpa-vbeln,                        " Número do documento de vendas e distribuição
    parvw TYPE vbpa-parvw,                        " Função do parceiro
    kunnr TYPE vbpa-kunnr,                        " Recebedor da Mercadoria (Número BP)
  END OF y_vbpa,

  BEGIN OF y_kna1,
    kunnr TYPE kna1-kunnr,                        " Nº cliente
    name1 TYPE kna1-name1,                        " Recebedor da Mercadoria (Nome)/Nome do Médico
  END OF y_kna1,

  BEGIN OF y_vbfa,
    vbelv TYPE vbfa-vbelv,                        " Remessa
    vbeln TYPE vbfa-vbeln,                        " Documento de vendas e distribuição subsequente
  END OF y_vbfa,

  BEGIN OF y_ser01,
    obknr   TYPE ser01-obknr,                     " Nº lista de objetos
    lief_nr TYPE ser01-lief_nr,                   " Remessa
  END OF y_ser01,

  BEGIN OF y_objk,
    obknr TYPE objk-obknr,                        " Nº lista de objetos
    matnr TYPE objk-matnr,                        " Nº do material
    sernr TYPE objk-sernr,                        " Número de Série
  END OF y_objk,

  BEGIN OF y_saida,
    vbeln  TYPE vbap-vbeln,                       " Ordem de Venda
    auart  TYPE vbak-auart,                       " Tipo de Documento
    docde  TYPE tvakt-bezei,                      " Tipo de Documento - Descrição
    docmde TYPE tvaut-bezei,                      " Motivo da Ordem - Descrição
    kunnr  TYPE vbpa-kunnr,                       " Recebedor da Mercadoria (Número BP)
    name1  TYPE kna1-name1,                       " Recebedor da Mercadoria (Nome)
    doctor TYPE kna1-name1,                       " Nome do Médico
    bstnk  TYPE vbak-bstnk,                       " Referência de Cliente
    vbelv  TYPE vbfa-vbelv,                       " Remessa
    matnr  TYPE vbap-matnr,                       " Material
    sernr  TYPE objk-sernr,                       " Número de Série
  END OF y_saida.

*----------------------------------------------------------------------*
* Tabela Interna                                                       *
*----------------------------------------------------------------------*
DATA: t_vbak     TYPE TABLE OF y_vbak,            " Cabeçalho do Documento de Venda
      t_vbap     TYPE TABLE OF y_vbap,            " Item do Documento de Venda
      t_tvakt    TYPE TABLE OF y_tvakt,           " Texto de Classe de Documento de Venda
      t_tvaut    TYPE TABLE OF y_tvaut,           " Texto de Motivo de Documento de Venda
      t_vbpa     TYPE TABLE OF y_vbpa,            " Parceiros de Negócios em Documentos de Venda
      t_kna1     TYPE TABLE OF y_kna1,            " Mestre de Clientes (Geral)
      t_vbfa     TYPE TABLE OF y_vbfa,            " Fluxo de Documentos de Vendas e Distribuição
      t_ser01    TYPE TABLE OF y_ser01,           " Cabeçalho do documento p/os nºs de série do fornecimento
      t_objk     TYPE TABLE OF y_objk,            " Lista de objetos manutenção
      t_saida    TYPE TABLE OF y_saida,           " Registros que serão exibidos na ALV
      t_fieldcat TYPE TABLE OF slis_fieldcat_alv. " Colunas que serão exibidas na ALV

*----------------------------------------------------------------------*
* Work Area                                                            *
*----------------------------------------------------------------------*
DATA: w_vbak     TYPE y_vbak,                     " Cabeçalho do Documento de Venda
      w_vbap     TYPE y_vbap,                     " Item do Documento de Venda
      w_tvakt    TYPE y_tvakt,                    " Texto de Classe de Documento de Venda
      w_tvaut    TYPE y_tvaut,                    " Texto de Motivo de Documento de Venda
      w_vbpa     TYPE y_vbpa,                     " Parceiros de Negócios em Documentos de Venda
      w_kna1     TYPE y_kna1,                     " Mestre de Clientes (Geral)
      w_vbfa     TYPE y_vbfa,                     " Fluxo de Documentos de Vendas e Distribuição
      w_ser01    TYPE y_ser01,                    " Cabeçalho do documento p/os nºs de série do fornecimento
      w_objk     TYPE y_objk,                     " Lista de objetos manutenção
      w_saida    TYPE y_saida,                    " Registros que serão exibidos na ALV
      w_fieldcat TYPE slis_fieldcat_alv.          " Colunas que serão exibidas na ALV

*----------------------------------------------------------------------*
* TYPE-POOLS - Importa uma estrutura Standard                          *
*----------------------------------------------------------------------*
TYPE-POOLS:
      slis.

*----------------------------------------------------------------------*
* DATA - Variáveis                                                     *
*----------------------------------------------------------------------*
DATA: l_message TYPE string,
      l_partner TYPE bu_partner,
      l_request TYPE REF TO cl_bupa_navigation_request,
      l_options TYPE REF TO cl_bupa_dialog_joel_options.

*----------------------------------------------------------------------*
* Tela de Seleção                                                      *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vkorg FOR vbak-vkorg,         " Organização de vendas
                  s_erdat FOR vbak-erdat.         " Data de criação do registro
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

*----------------------------------------------------------------------*
* Execução da ALV                                                      *
*----------------------------------------------------------------------*
  PERFORM zf_seleciona_dados.
  PERFORM zf_processa_dados.
  PERFORM zf_monta_alv.
  PERFORM zf_exibe_alv.

*----------------------------------------------------------------------*
* FORMs                                                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form ZF_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*& Seleciona 9 tabelas: vbak, vbap, tvakt, tvaut, vbpa, kna1,          *
*& vbfa, ser01, objk.                                                  *
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados.

* Seleciona a tabela vbak(Cabeçalho do Documento de Venda).
  SELECT vbeln erdat auart augru vkorg bstnk bstdk bname
    FROM vbak
    INTO TABLE t_vbak
    WHERE vkorg IN s_vkorg
      AND erdat IN s_erdat.
  IF sy-subrc = 0.

*   Seleciona a tabela tvakt(Texto de Classe de Documento de Venda).
    SELECT auart, bezei
      FROM tvakt
      INTO TABLE @t_tvakt
      FOR ALL ENTRIES IN @t_vbak
      WHERE auart = @t_vbak-auart.
*   Seleciona a tabela tvaut (Texto de Motivo de Documento de Venda).
    SELECT augru, bezei
      FROM tvaut
      INTO TABLE @t_tvaut
      FOR ALL ENTRIES IN @t_vbak
      WHERE augru = @t_vbak-augru.

*   Seleciona a tabela vbap(Item do Documento de Venda).
    SELECT vbeln, matnr
      FROM vbap
      INTO TABLE @t_vbap
      FOR ALL ENTRIES IN @t_vbak
      WHERE vbeln = @t_vbak-vbeln.
    IF sy-subrc = 0.
*     Seleciona a tabela vbpa(Parceiros de Negócios em Documentos de Venda).
      SELECT vbeln, parvw, kunnr
        FROM vbpa
        INTO TABLE @t_vbpa
        FOR ALL ENTRIES IN @t_vbap
        WHERE vbeln = @t_vbap-vbeln.
      IF sy-subrc = 0.
*       Seleciona a tabela kna1(Mestre de Clientes (Geral)).
        SELECT kunnr, name1
          FROM kna1
          INTO TABLE @t_kna1
          FOR ALL ENTRIES IN @t_vbpa
          WHERE kunnr = @t_vbpa-kunnr.
      ELSE.
        CONCATENATE TEXT-014
                    '''' TEXT-020 ''''
                    TEXT-015
                    INTO l_message SEPARATED BY space.
        MESSAGE l_message TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.

*     Seleciona a tabela vbfa(Fluxo de Documentos de Vendas e Distribuição).
      SELECT vbelv, vbeln
        FROM vbfa
        INTO TABLE @t_vbfa
        FOR ALL ENTRIES IN @t_vbap
        WHERE vbelv = @t_vbap-vbeln.
      IF sy-subrc = 0.
*       Seleciona a tabela ser01(Cabeçalho do documento p/os nºs de série do fornecimento).
        SELECT obknr, lief_nr
          FROM ser01
          INTO TABLE @t_ser01
          FOR ALL ENTRIES IN @t_vbfa
          WHERE lief_nr = @t_vbfa-vbeln.
        IF sy-subrc = 0.
*         Seleciona a tabela objk(Lista de objetos manutenção).
          SELECT obknr, matnr, sernr
            FROM objk
            INTO TABLE @t_objk
            FOR ALL ENTRIES IN @t_ser01
            WHERE obknr = @t_ser01-obknr.
        ENDIF.
      ELSE.
        CONCATENATE TEXT-014
                    '''' TEXT-022 ''''
                    TEXT-015
                    INTO l_message SEPARATED BY space.
        MESSAGE l_message TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.

    ELSE.
      CONCATENATE TEXT-014
                  '''' TEXT-017 ''''
                  TEXT-015
                  INTO l_message SEPARATED BY space.
      MESSAGE l_message TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
    CONCATENATE TEXT-014
                '''' TEXT-016 ''''
                TEXT-015
                INTO l_message SEPARATED BY space.
    MESSAGE l_message TYPE 'I' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_PROCESSA_DADOS                                              *
*&---------------------------------------------------------------------*
*& Processa os dados selecionados.                                     *
*&---------------------------------------------------------------------*
FORM zf_processa_dados.

* Ordena todas as tabelas.
  SORT t_vbak  BY vbeln auart augru bname.
  SORT t_vbap  BY vbeln.
  SORT t_tvakt BY auart bezei.
  SORT t_tvaut BY augru bezei.
  SORT t_vbpa  BY vbeln parvw kunnr.
  SORT t_kna1  BY kunnr name1.
  SORT t_vbfa  BY vbelv vbeln.
  SORT t_ser01 BY obknr lief_nr.
  SORT t_objk  BY obknr matnr sernr.

* Loop na tabela items de documento de venda (vbap).
  LOOP AT t_vbap INTO w_vbap.

    w_saida-vbeln = w_vbap-vbeln.                 " Ordem de Venda
    w_saida-matnr = w_vbap-matnr.                 " Material
    CLEAR w_vbak.
    READ TABLE t_vbak
      INTO w_vbak
      WITH KEY vbeln = w_vbap-vbeln  BINARY SEARCH.
    IF sy-subrc = 0.
      w_saida-auart = w_vbak-auart.               " Tipo de Documento
      w_saida-bstnk = w_vbak-bstnk.               " Referência de Cliente
      w_saida-bstdk = w_vbak-bstdk.               " Data de Envio

      CLEAR w_tvakt.
      READ TABLE t_tvakt
        INTO w_tvakt
        WITH KEY auart = w_vbak-auart  BINARY SEARCH.
      IF sy-subrc = 0.
        w_saida-docde = w_tvakt-bezei.            " Tipo de Documento - Descrição
      ENDIF.
      CLEAR w_tvaut.
      READ TABLE t_tvaut
        INTO w_tvaut
        WITH KEY augru = w_vbak-augru  BINARY SEARCH.
      IF sy-subrc = 0.
        w_saida-docmde = w_tvaut-bezei.           " Motivo da Ordem - Descrição
      ENDIF.

      CLEAR w_vbpa.
      CLEAR w_kna1.
      READ TABLE t_vbpa
        INTO w_vbpa
        WITH KEY vbeln = w_vbap-vbeln
                 parvw = 'WE'  BINARY SEARCH.
      IF sy-subrc = 0.
        w_saida-kunnr = w_vbpa-kunnr.             " Recebedor da Mercadoria (Número BP) **
        READ TABLE t_kna1
          INTO w_kna1
          WITH KEY kunnr = w_vbpa-kunnr BINARY SEARCH.
        IF sy-subrc = 0.
          w_saida-name1 = w_kna1-name1.           " Recebedor da Mercadoria (Nome)
        ENDIF.
      ENDIF.

      CLEAR w_vbpa.
      CLEAR w_kna1.
      READ TABLE t_vbpa
        INTO w_vbpa
        WITH KEY vbeln = w_vbap-vbeln
                 parvw = 'MD' BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE t_kna1
          INTO w_kna1
          WITH KEY kunnr = w_vbpa-kunnr BINARY SEARCH.
        IF sy-subrc = 0.
          IF w_kna1-kunnr IS NOT INITIAL.
            w_saida-doctor = w_kna1-name1.        " Nome do Médico
          ELSE.
            w_saida-doctor = w_vbak-bname.        " Nome do Médico
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR w_vbfa.
      READ TABLE t_vbfa
        INTO w_vbfa
        WITH KEY vbelv = w_vbap-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        w_saida-vbelv = w_vbfa-vbeln.             " Remessa
        CLEAR w_ser01.
        READ TABLE t_ser01
          INTO w_ser01
          WITH KEY lief_nr = w_vbfa-vbeln BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR w_objk.
          READ TABLE t_objk
            INTO w_objk
            WITH KEY obknr = w_ser01-obknr
                     matnr = w_vbap-matnr BINARY SEARCH.
          IF sy-subrc = 0.
            w_saida-sernr = w_objk-sernr.         " Número de Série
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      CONCATENATE TEXT-014
                  '''' TEXT-016 ''''
                  TEXT-015
                  INTO l_message SEPARATED BY space.
      MESSAGE l_message TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    APPEND w_saida TO t_saida.
    CLEAR: w_saida, w_vbap.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_MONTA_ALV                                                   *
*&---------------------------------------------------------------------*
*& Preenche as colunas da ALV.                                         *
*&---------------------------------------------------------------------*
FORM zf_monta_alv.

  PERFORM zf_adiciona_coluna USING 'VBELN'  'T_SAIDA' TEXT-002 12 'X' 'C'.  " Ordem de Venda
  PERFORM zf_adiciona_coluna USING 'AUART'  'T_SAIDA' TEXT-003 13 'Z' 'C'.  " Tipo de Documento
  PERFORM zf_adiciona_coluna USING 'DOCDE'  'T_SAIDA' TEXT-004 20 'Z' 'Z'.  " Descrição
  PERFORM zf_adiciona_coluna USING 'DOCMDE' 'T_SAIDA' TEXT-005 15 'Z' 'Z'.  " Motivo da Ordem
  PERFORM zf_adiciona_coluna USING 'KUNNR'  'T_SAIDA' TEXT-006 20 'X' 'C'.  " Recebedor da Mercadoria
  PERFORM zf_adiciona_coluna USING 'NAME1'  'T_SAIDA' TEXT-007 18 'Z' 'Z'.  " Nome
  PERFORM zf_adiciona_coluna USING 'BSTNK'  'T_SAIDA' TEXT-009 18 'Z' 'C'.  " Referência de Cliente
  PERFORM zf_adiciona_coluna USING 'BSTDK'  'T_SAIDA' TEXT-010 12 'Z' 'C'.  " Data Envio
  PERFORM zf_adiciona_coluna USING 'VBELV'  'T_SAIDA' TEXT-011 12 'X' 'C'.  " Remessa
  PERFORM zf_adiciona_coluna USING 'MATNR'  'T_SAIDA' TEXT-012 12 'Z' 'C'.  " Material
  PERFORM zf_adiciona_coluna USING 'SERNR'  'T_SAIDA' TEXT-013 15 'Z' 'C'.  " Número de Série

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_ADICIONA_COLUNA                                             *
*&---------------------------------------------------------------------*
*& Adiciona uma coluna na ALV.
*&---------------------------------------------------------------------*
*& -->  p_campo       Nome do Campo que define o tipo de coluna.       *
*& -->  p_tabela      Nome da Tabela onde o campo será selecionado.    *
*& -->  p_texto       Texto a ser exibido como título da coluna.       *
*& -->  p_tamanho     Tamanho da coluna.                               *
*& -->  p_hotspot     Definição de um campo como Hotspot.              *
*&                      X - Coluna é hotspot(clicável)                 *
*&                      Z - Coluna não é hotspot(clicável)             *
*& -->  p_alinhamento Define o alinhamento da coluna.                  *
*&                      C - Centralizado                               *
*&                      Z - Alinhamento padrão                         *
*&---------------------------------------------------------------------*
FORM zf_adiciona_coluna USING p_campo p_tabela p_texto p_tamanho p_hotspot p_alinhamento.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = p_campo.
  w_fieldcat-tabname   = p_tabela.
  w_fieldcat-seltext_l = p_texto.
  w_fieldcat-outputlen = p_tamanho.

* Define o alinhamento da coluna
  IF p_alinhamento     = 'C'.
    w_fieldcat-just    = 'C'.
  ENDIF.

* Define se a coluna é hotspot(clicável)
  IF p_hotspot         = 'X'.
    w_fieldcat-hotspot = 'X'.
  ENDIF.

  APPEND w_fieldcat TO t_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_ABRE_PARCEIRO                                               *
*&---------------------------------------------------------------------*
*& Abre parceiro de negócios na transação BP.                          *
*&---------------------------------------------------------------------*
*& p_bp -> número do parceiro de negócios                              *
*&---------------------------------------------------------------------*
FORM zf_abre_parceiro USING p_bp.

* Converte o parâmetro com o número do cliente(BP)
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = p_bp
    IMPORTING
      OUTPUT = l_partner.

* Cria um objeto, utilizado para abrir a transação BP
  CREATE OBJECT l_request.

* Atribui o número do cliente ao objeto l_request, assim como outras configurações:
  CALL METHOD l_request->set_partner_number( l_partner ).
  CALL METHOD l_request->set_maintenance_id
    EXPORTING
      iv_value = l_request->gc_maintenance_id_partner.
  CALL METHOD l_request->set_bupa_activity
    EXPORTING
      iv_value = l_request->gc_activity_display.

* Cria um objeto l_options, também utilizado para abrir a transação BP.
  CREATE OBJECT l_options.

* Configura l_options para que a transação seja exibida corretamente.
  CALL METHOD l_options->set_locator_visible( SPACE ).

* Abre a transação BP, na tela de manutenção(detalhes) do parceiro de negócios.
  CALL METHOD cl_bupa_dialog_joel=>start_with_navigation
    EXPORTING
      iv_request              = l_request
      iv_options              = l_options
      iv_in_new_internal_mode = abap_true
      iv_in_new_window        = abap_false
    EXCEPTIONS
      already_started         = 1
      not_allowed             = 2
      OTHERS                  = 3.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_ABRE_TRANSACAO                                              *
*&---------------------------------------------------------------------*
*& Após dois cliques na coluna desejada, abre a transação que exibe    *
*& o campo e digita o valor clicado.                                   *
*&---------------------------------------------------------------------*
FORM zf_abre_transacao USING p_codigo_funcao  LIKE sy-ucomm
                             p_coluna_atual   TYPE slis_selfield.

  CASE p_coluna_atual-fieldname.
*   Abre transação VA03 com a Ordem de Venda selecionada.
    WHEN 'VBELN'.
      READ TABLE t_saida INTO w_saida INDEX p_coluna_atual-tabindex.
      IF sy-subrc = 0.
        SET PARAMETER ID 'AUN' FIELD w_saida-vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.

*   Abre transação BP com o Recebedor da Mercadoria selecionado.
    WHEN 'KUNNR'.
      READ TABLE t_saida INTO w_saida INDEX p_coluna_atual-tabindex.
      IF sy-subrc = 0.
        PERFORM zf_abre_parceiro USING w_saida-kunnr.
      ENDIF.

*   Abre transação VL03 com a Remessa selecionada.
    WHEN 'VBELV'.
      READ TABLE t_saida INTO w_saida INDEX p_coluna_atual-tabindex.
      IF sy-subrc = 0.
        SET PARAMETER ID 'VL' FIELD w_saida-vbelv.
        CALL TRANSACTION 'VL03' AND SKIP FIRST SCREEN.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_EXIBE_ALV                                                   *
*&---------------------------------------------------------------------*
*& Exibe o relatório ALV na tela.                                      *
*&---------------------------------------------------------------------*
FORM zf_exibe_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat        = t_fieldcat             " tabela com as colunas da ALV
      i_callback_program = sy-repid
      i_callback_user_command = 'ZF_ABRE_TRANSACAO'
    TABLES
      t_outtab           = t_saida                " tabela com os registros da ALV
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.