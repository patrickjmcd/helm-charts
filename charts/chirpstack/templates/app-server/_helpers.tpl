{{- define "chirpstack.appserver.labels" -}}
app.kubernetes.io/name: {{ template "chirpstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.appserver.image.tag }}
app.kubernetes.io/component: "{{ .Values.appserver.name }}"
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "chirpstack.appserver.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.appserver.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.appserver.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "chirpstack.appserver.selector" -}}
app.kubernetes.io/name: {{ template "chirpstack.appserver.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "chirpstack.appserver.postgres.dsn" -}}
{{- printf "user=$(POSTGRESQL__USER) password=$(POSTGRESQL__PASSWORD) host=%s dbname=%s sslmode=%s" .Values.appserver.postgres.host .Values.appserver.postgres.dbname .Values.appserver.postgres.sslmode -}}
{{- end -}}

{{- define "chirpstack.appserver.public.host" -}}
{{- if (not .Values.appserver.api.public_host) -}}
{{ template "chirpstack.appserver.fullname" . }}-api.{{ .Release.Namespace }}.svc.{{ .Values.common.dns }}:8001
{{- else -}}
{{- .Values.appserver.api.public_host -}}  
{{- end -}}
{{- end -}}

{{- define "chirpstack.appserver.integration" -}}
{{- if .Values.appserver.integration.mqtt.enabled -}}
{{- $appserverMQTTSecret := .Values.appserver.integration.mqtt.existingSecret | default "secret.not.set"  -}}
- name: APPLICATION_SERVER__INTEGRATION__MQTT__SERVER
  value: {{ .Values.appserver.integration.mqtt.server }}
- name: APPLICATION_SERVER__INTEGRATION__MQTT__USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $appserverMQTTSecret }}
      key: username
      optional: true
- name: APPLICATION_SERVER__INTEGRATION__MQTT__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $appserverMQTTSecret }}
      key: password
      optional: true
- name: APPLICATION_SERVER__INTEGRATION__MQTT__CLIENT_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- end }}
{{- if .Values.appserver.integration.kafka.enabled }}
{{- $appserverKafkaSecret := .Values.appserver.integration.kafka.existingSecret | default "secret.not.set"  }}
- name: APPLICATION_SERVER__INTEGRATION__KAFKA__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $appserverKafkaSecret }}
      key: {{ default "password" .Values.appserver.integration.kafka.existingSecretPasswordKey }}  
      optional: true
{{- end }}
{{- end -}}

{{- define "chirpstack.appserver.integration.enabled" -}}
{{- $integrations := list }}
{{- range $key, $value := .Values.appserver.integration -}}
{{- if $value.enabled -}}
{{- $integrations = append $integrations $key -}}
{{- end -}}
{{- end -}}
["{{ join "\",\"" $integrations }}"]
{{- end -}}


{{- define "chirpstack.appserver.external.url" -}}
{{- if .Values.appserver.istio.gateway.tls.enabled -}}
https://{{ .Values.appserver.istio.gateway.host }}
{{- else -}}
http://{{ .Values.appserver.istio.gateway.host }}  
{{- end -}}
{{- end -}}