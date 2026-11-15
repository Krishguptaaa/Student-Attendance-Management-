package com.example.attendance.unit;

import com.example.attendance.dto.CourseRequest;
import com.example.attendance.exception.DuplicateResourceException;
import com.example.attendance.exception.ResourceNotFoundException;
import com.example.attendance.model.Course;
import com.example.attendance.repository.CourseRepository;
import com.example.attendance.service.CourseService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CourseServiceTest {

    @Mock
    private CourseRepository courseRepository;

    @InjectMocks
    private CourseService courseService;

    @Test
    void createUsesRequestedCreditsAndSavesCourse() {
        CourseRequest request = new CourseRequest("CS301", "Operating Systems", "Systems course", 3);
        when(courseRepository.existsByCode("CS301")).thenReturn(false);
        when(courseRepository.save(ArgumentMatchers.any(Course.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Course created = courseService.create(request);

        assertEquals("CS301", created.getCode());
        assertEquals("Operating Systems", created.getName());
        assertEquals("Systems course", created.getDescription());
        assertEquals(3, created.getCredits());
        verify(courseRepository).save(ArgumentMatchers.any(Course.class));
    }

    @Test
    void createRejectsDuplicateCourseCodeWithoutSaving() {
        CourseRequest request = new CourseRequest("CS301", "Operating Systems");
        when(courseRepository.existsByCode("CS301")).thenReturn(true);

        assertThrows(DuplicateResourceException.class, () -> courseService.create(request));

        verify(courseRepository, never()).save(ArgumentMatchers.any(Course.class));
    }

    @Test
    void findByIdRejectsMissingCourse() {
        when(courseRepository.findById(42L)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> courseService.findById(42L));
    }
}
