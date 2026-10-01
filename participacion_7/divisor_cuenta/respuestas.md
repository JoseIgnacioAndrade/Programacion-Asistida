# Respuestas — Participación 7: Vibe coding vs. SDD con GitHub Spec Kit

## Tabla de Métricas y Configuración

| Métrica | Rama Vibe | Rama SDD |
|---|---|---|
| Iteraciones (mensajes de corrección) | [Ej: 4] | [Ej: 1] |
| Casos de aceptación que cumple (0–6) | [Ej: 5/6] | [Ej: 6/6] |
| Pruebas automatizadas que pasan | [Ej: No aplica / Parcial] | [Ej: Todos en verde] |
| Archivos en `lib/` | [Ej: 2] | [Ej: 9] |
| Líneas de código en `lib/` | [Ej: ~80] | [Ej: ~250] |
| ¿`domain/` depende de Flutter? | [Ej: Sí] | [Ej: No] |
| ¿Existe separación `presentation/domain/data`? | [Ej: No] | [Ej: Sí] |
| ¿El agente agregó algo que nadie pidió? | [Ej: Sí, animaciones extras] | [Ej: No, estrictamente el MVP] |
| ¿Se puede agregar otra estrategia sin modificar el cálculo existente? | [Ej: No] | [Ej: Sí (gracias a OCP/LSP)] |

* **Agente, modelo y configuración utilizados:** [Ej: Gemini CLI / Claude Code / Antigravity Agent, modelo gemini-1.5-pro, nivel de razonamiento estándar].
* **Archivo de instrucciones utilizado:** [Ej: AGENTS.md / CLAUDE.md].
* **Caso de Git aplicado (Parte 1.5):** [Ej: Caso C / Se creó un repositorio propio dentro de la carpeta divisor_cuenta].
* **Tiempo aproximado (métrica secundaria):** Vibe: [Ej: 10 min] / SDD: [Ej: 35 min].

---

### 1. Análisis de cumplimiento e iteraciones
El enfoque **SDD** cumplió de forma exacta y a la primera los seis escenarios gracias a la estructura previa de especificaciones y la constitución. La rama **Vibe** requirió más iteraciones de corrección porque el agente tomó decisiones estéticas y de arquitectura de forma improvisada, obligándome a retroceder y pedir ajustes sobre la marcha. Las decisiones explícitas en SDD (como el redondeo y manejo de errores) quedaron definidas en los artefactos, mientras que en Vibe el agente tuvo que adivinarlas en la conversación. *(El tiempo es secundario ya que SDD requiere más planificación inicial, pero garantiza mayor mantenibilidad).*

### 2. Pruebas de SDD en la rama Vibe (Parte 10)
Al traer la carpeta `test/` de `sdd` a `vibe` y ejecutar `flutter test`, **[escribe aquí si compiló o no, ej: no compilaron]**. 
* **Primer error obtenido:** `[Pega aquí el error si falló la compilación, ej: Error: The method 'CalcularDivision' isn't defined...]`
* **Justificación:** Este error no demuestra un fallo funcional de la app Vibe en su interfaz, sino una **diferencia absoluta de arquitectura y testabilidad**. La rama Vibe no cuenta con la separación en capas (`domain/data`) ni con las clases abstractas e interfaces (`EstrategiaRedondeo`) que las pruebas automatizadas exigen.

### 3. Verificaciones de SOLID (Parte 9.5)
* **DIP y capas (dominio libre de Flutter):** La rama **SDD** pasa la verificación (`grep` no devuelve nada en `lib/domain/`). La rama **Vibe** la **falla**, ya que todo está acoplado en un solo archivo con dependencias de Flutter.
* **Principio de Responsabilidad Única (SRP):** En SDD se respeta estrictamente (el cálculo no valida ni formatea); en Vibe la lógica de negocio, validación y UI conviven en el mismo widget.
* **Regla de la Constitution:** La regla de arquitectura y la separación en capas definida en la Constitution aseguran que el dominio sea puro y mantenga la dirección correcta de dependencias (`presentation -> domain <- data`).

### 4. Preguntas de `/speckit-clarify`
* **Pregunta 1:** *[Copia una pregunta relevante que te hizo Spec Kit, ej: "¿Qué comportamiento exacto debe tener la aplicación si el número de personas ingresado es un decimal en lugar de un entero?"]*
* **Ambigüedad que destapó:** Obligó a definir el tipo de dato estricto para el número de personas, evitando que el agente asumiera comportamientos erróneos. *(Si no hizo preguntas relevantes, indica qué información de la spec ya cubría los casos y cómo en la rama Vibe esas decisiones las tomó el agente por su cuenta sin consultarte).*

### 5. Análisis de `git diff vibe sdd --stat`
La rama **[Vibe / SDD]** agregó código o funcionalidades no solicitadas. Por ejemplo, **[describe brevemente si el agente agregó elementos extra, ej: la rama Vibe agregó un selector de propinas predeterminadas con botones flotantes y diseño de gradientes que nadie pidió, mientras que SDD se limitó estrictamente al alcance del MVP]**.

### 6. Alternativas a Spec Kit y uso de Vibe coding
* **Alternativa analizada (ej. OpenSpec / Kiro):** OpenSpec se centra en flujos abiertos basados en especificaciones ligeras orientadas a la colaboración agnóstica de agentes, prefiriéndose frente a Spec Kit cuando se busca una integración más flexible con múltiples LLMs sin una estructura de archivos tan rígida.
* **Cuándo elegir Vibe coding:** Sería razonable y eficiente elegir Vibe coding en una situación real y pequeña como la creación de un prototipo rápido (*proof of concept*), un script desechable de una sola ejecución, o una landing page estática donde la mantenibilidad a largo plazo y la arquitectura limpia no son prioridades críticas.