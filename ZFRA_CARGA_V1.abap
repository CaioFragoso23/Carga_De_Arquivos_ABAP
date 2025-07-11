*&---------------------------------------------------------------------*
*& Report ZFRA_CARGA_V1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
" Programa de Cadastro de Reservas em um Hotel (com Carga de CSV/Excel)
*--------------------------------------------------------------------*
REPORT zfra_carga_v1.

INCLUDE zfra_carga_v1_top. "Vari�veis Globais
INCLUDE zfra_carga_v1_f01. "L�gica do programa
INCLUDE zfra_carga_v1_pbo. "Process Before Output (Gera��o de Tela)
INCLUDE zfra_carga_v1_pai. "Process After Input   (Rea��o a cliques e eventos)

START-OF-SELECTION.
  IF p_hosp IS NOT INITIAL. "Se campo de h�spede estiver vazio

    PERFORM zf_le_hospede.
    IF sy-subrc EQ 0.
      cl_demo_output=>display( it_tab_hospede ).
    ENDIF.

  ELSEIF p_qrto IS NOT INITIAL. "Se campo de quarto estiver vazio

    PERFORM zf_le_quarto.
    IF sy-subrc EQ 0.
      cl_demo_output=>display( it_tab_saida_quarto ).
    ENDIF.


  ELSEIF p_rese IS NOT INITIAL. "Se campo de reservas estiver vazio

    PERFORM zf_le_reservas.
    IF sy-subrc EQ 0.
      cl_demo_output=>display( it_tab_saida_reservas ).
    ENDIF.

  ENDIF.
