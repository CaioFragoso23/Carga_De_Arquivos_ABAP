*&---------------------------------------------------------------------*
*& Include          ZFRA_CARGA_V1_TOP
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&                  Var�aveis Globais                                 *
*&--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*-------------------Tabelas------------------------------------------*
*--------------------------------------------------------------------*
TABLES:
*--------------------------------------------------------------------*
  "   Tabelas de H�spede, Quarto e Reservas "
*--------------------------------------------------------------------*
  zfra_hospede,
  zfra_quarto,
  zfra_reservas,
*--------------------------------------------------------------------*
  sscrfields. "Tabela utilizada para definir bot�o na tela de sele��o
*--------------------------------------------------------------------*
*-------------------Tipos--------------------------------------------*
*--------------------------------------------------------------------*
TYPES: BEGIN OF tp_arq,
         linha(300) TYPE c,
       END OF tp_arq,

       BEGIN OF tp_tab_hospede,
         id       TYPE zfra_ed_id_hospede,
         nome     TYPE zfra_ed_nome_hospede,
         endereco TYPE zfra_ed_endereco_hospede,
         telefone TYPE zfra_ed_telefone_hospede,
       END OF tp_tab_hospede,

       BEGIN OF tp_tab_quarto_char,
         numero(3) TYPE c,
         tipo(1)   TYPE c,
         moeda(3)  TYPE c,
         preco(7)  TYPE c,
       END OF tp_tab_quarto_char,

       BEGIN OF tp_tab_reservas_char,
         id(6)         TYPE c,
         checkin(11)   TYPE c,
         checkout(11)  TYPE c,
         id_hospede(6) TYPE c,
         num_quarto(6) TYPE c,
       END OF tp_tab_reservas_char.

*--------------------------------------------------------------------*
*-------------------Vari�veis----------------------------------------*
*--------------------------------------------------------------------*

DATA: it_arq                TYPE TABLE OF tp_arq,
      wa_arq                TYPE          tp_arq,
      it_tab_hospede        TYPE TABLE OF tp_tab_hospede,
      wa_tab_hospede        TYPE          tp_tab_hospede,
      it_tab_quarto         TYPE TABLE OF tp_tab_quarto_char,
      wa_tab_quarto         TYPE          tp_tab_quarto_char,
      it_tab_saida_quarto   TYPE TABLE OF zfra_quarto,
      wa_tab_saida_quarto   TYPE          zfra_quarto,
      it_tab_reservas       TYPE TABLE OF tp_tab_reservas_char,
      wa_tab_reservas       TYPE          tp_tab_reservas_char,
      lv_id                 TYPE          zfra_ed_id_hospede,
      lv_path               TYPE          string,
      lv_preco              TYPE          c,
      it_tab_saida_reservas TYPE TABLE OF zfra_reservas,
      wa_tab_saida_reservas TYPE          zfra_reservas,
      functxt               TYPE          smp_dyntxt.

*--------------------------------------------------------------------*
*-------------------Tela de Sele��o----------------------------------*
*--------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
  PARAMETERS: p_file TYPE rlgrap-filename. "Par�metro do tipo nome do arquivo (utilizado pelo gui_upload)
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_hosp RADIOBUTTON GROUP grp1,  "Radio Button de H�spede
              p_qrto RADIOBUTTON GROUP grp1,  "Radio Button de Quarto
              p_rese RADIOBUTTON GROUP grp1.  "Radio Button de Reserva
SELECTION-SCREEN END OF BLOCK b02.

*--------------------------------------------------------------------*
*-------------------Bot�o Tela de Sele��o----------------------------*
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
" Fun��o para criar bot�o de "Arquivo Modelo"
*--------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

INITIALIZATION.
  functxt-text = 'Arquivo Modelo'.
  functxt-icon_id = icon_display_text.
  functxt-icon_text = 'Arquivo Modelo'.
  sscrfields-functxt_01 = functxt.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
  " POPUP do bot�o "Arquivo Modelo"
*--------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF sscrfields-ucomm EQ 'FC01'.
    CALL SCREEN '0100' STARTING AT '5' '10'
                       ENDING AT   '90' '30'.
  ENDIF.

*--------------------------------------------------------------------*
  " POPUP para puxar arquivo local
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = p_file.
*--------------------------------------------------------------------*
