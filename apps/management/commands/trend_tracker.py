from django.core.management.base import BaseCommand

class Command(BaseCommand):

    TEST = "My test Cmd"
    def handle(self, *args, **options):
        print(self.TEST)
        
