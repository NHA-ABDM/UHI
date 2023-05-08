package in.gov.abdm.uhi.registry.entity;

import java.io.Serializable;
import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.EntityListeners;
import javax.persistence.MappedSuperclass;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import lombok.Data;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Data
public abstract class DateAudit implements Serializable {
	private static final long serialVersionUID = 1L;
	 @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
	 @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
